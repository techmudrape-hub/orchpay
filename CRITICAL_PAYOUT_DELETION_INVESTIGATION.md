# CRITICAL: Payout Data Actually Being Deleted

## Confirmed Issue

Transaction `DP2026030417553292BE6E` appears in frontend but **NOT in database**. This means data is being **actively deleted**, not just hidden by queries.

## Immediate Actions Required

### 1. Check Database Configuration

```bash
cd /var/www/moneyone/moneyone/backend
python3 check_database_config.py
```

This will show:
- Which database you're connected to
- If there are multiple databases
- Recent transactions in the database

### 2. Check Environment Variables

```bash
# Check backend .env
cat /var/www/moneyone/moneyone/backend/.env | grep DB_

# Check if different instances have different configs
sudo find /var/www -name ".env" -exec echo "=== {} ===" \; -exec grep DB_ {} \;
```

### 3. Enable Query Logging (CRITICAL)

```bash
# Enable MySQL query logging to catch DELETE queries
sudo mysql -u root -p -e "SET GLOBAL general_log = 'ON';"
sudo mysql -u root -p -e "SET GLOBAL general_log_file = '/var/log/mysql/general.log';"

# Watch for DELETE queries in real-time
sudo tail -f /var/log/mysql/general.log | grep -i delete
```

### 4. Check for Cleanup Scripts

```bash
# Check crontab for scheduled deletions
crontab -l
sudo crontab -l

# Check for any cleanup scripts
find /var/www/moneyone -name "*clean*" -o -name "*delete*" -o -name "*purge*"

# Check systemd timers
systemctl list-timers
```

### 5. Check Application Logs

```bash
# Check backend logs for DELETE operations
sudo journalctl -u backend -n 1000 | grep -i delete

# Check application logs
tail -n 1000 /var/log/backend.log | grep -i "DELETE\|payout_transactions"
```

### 6. Check Load Balancer Configuration

```bash
# If using AWS ALB, check target groups
aws elbv2 describe-target-groups

# Check if sticky sessions are enabled
aws elbv2 describe-target-group-attributes --target-group-arn <your-tg-arn>
```

## Possible Root Causes

### 1. Transaction Rollback (MOST LIKELY)
- INSERT happens but never commits
- Transaction times out and rolls back
- Frontend shows data before rollback

**Fix:**
- Add explicit `conn.commit()` after INSERT
- Check for any `conn.rollback()` in error handlers
- Ensure autocommit is properly configured

### 2. Multiple Database Instances
- Frontend reads from Database A
- Your script reads from Database B
- Data exists in A but not in B

**Fix:**
- Verify all instances use same database
- Check .env files on all servers
- Consolidate to single database

### 3. Scheduled Cleanup Job
- Cron job or scheduled task deleting old records
- Cleanup script running every few hours
- Data retention policy deleting records

**Fix:**
- Check crontab and systemd timers
- Search for cleanup scripts
- Disable any data deletion jobs

### 4. Frontend Caching
- Frontend caches API response
- Shows cached data even after DB deletion
- Cache expires after refresh

**Fix:**
- Clear browser cache
- Check API response headers for caching
- Disable frontend caching for reports

### 5. Database Replication Lag
- Master-slave replication setup
- Frontend reads from slave (has data)
- Your script reads from master (no data)
- Replication lag or failure

**Fix:**
- Check replication status
- Ensure reading from same database
- Fix replication if broken

## Emergency Fix

If data is being deleted, immediately:

### 1. Backup Database NOW

```bash
mysqldump -u root -p moneyone_db > emergency_backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Check Transaction Commit

Edit `backend/payout_routes.py` around line 85-90:

```python
cursor.execute("""
    INSERT INTO payout_transactions ...
""", (...))

# ADD THIS LINE IF MISSING:
conn.commit()
print(f"✅ Transaction committed: {txn_id}")
```

### 3. Add Transaction Logging

Add this after every INSERT:

```python
cursor.execute("""
    INSERT INTO payout_transactions ...
""", (...))
conn.commit()

# Verify it was inserted
cursor.execute("SELECT * FROM payout_transactions WHERE txn_id = %s", (txn_id,))
verify = cursor.fetchone()
if verify:
    print(f"✅ VERIFIED IN DB: {txn_id}")
else:
    print(f"❌ NOT FOUND IN DB: {txn_id}")
```

### 4. Monitor in Real-Time

```bash
# Terminal 1: Watch MySQL queries
sudo tail -f /var/log/mysql/general.log

# Terminal 2: Watch application logs
sudo journalctl -u backend -f

# Terminal 3: Monitor database
watch -n 1 'mysql -u root -p -e "SELECT COUNT(*) FROM moneyone_db.payout_transactions WHERE created_at >= NOW() - INTERVAL 1 HOUR"'
```

## Next Steps

1. Run `python3 check_database_config.py` immediately
2. Enable MySQL query logging
3. Check for any DELETE queries in logs
4. Verify transaction commits are happening
5. Check if multiple databases exist
6. Monitor for 1-2 hours to catch deletion in action

## Contact Points

If issue persists:
1. Check with team if anyone has database access
2. Review recent code deployments
3. Check if any database maintenance scripts were added
4. Verify no one is manually deleting records

This is a **CRITICAL DATA LOSS ISSUE** - needs immediate attention!
