# Balance Fix - Quick Reference Card

## Problem
Balance flickering: ₹999.88 → ₹1,101.13 → ₹999.88 → ₹1,101.13

## Root Cause
Load Balancer + Multiple Instances = Different instances showing different data

## Quick Fix (Do This First) - 5 Minutes

### Enable Sticky Sessions on AWS ALB

1. AWS Console → EC2 → Load Balancers
2. Select your ALB → Target Groups tab
3. Select target group → Actions → Edit attributes
4. Enable stickiness → Load balancer generated cookie
5. Duration: 86400 seconds
6. Save

**Result:** Same user always hits same instance (temporary relief)

## Permanent Fix - 30 Minutes

### Step 1: Upload 4 Files to ALL Instances

Files to upload:
```
backend/database.py
backend/wallet_service.py
backend/wallet_routes.py
backend/payout_routes.py
```

### Step 2: Restart Service on Each Instance

```bash
ssh ubuntu@instance-ip
cd /home/ubuntu/moneyone_backend/backend
sudo systemctl restart moneyone-backend
sudo systemctl status moneyone-backend
```

### Step 3: Verify

```bash
# Test balance consistency
for i in {1..5}; do
  curl -s https://api.orchpay.in/wallet/overview \
    -H "Authorization: Bearer TOKEN" | jq '.data.balance'
done

# All values should be identical!
```

## What Changed

### Row-Level Locking
```sql
-- Before
SELECT balance FROM merchant_wallet WHERE merchant_id = 'M001'

-- After
SELECT balance FROM merchant_wallet WHERE merchant_id = 'M001' FOR UPDATE
```

**Effect:** Prevents race conditions, ensures consistency

### READ COMMITTED Isolation
```python
cursor.execute("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED")
```

**Effect:** Always reads latest committed data

### No-Cache Headers
```python
response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate'
```

**Effect:** Prevents browser caching

### Balance in Response
```python
return jsonify({'wallet_balance': updated_balance, ...})
```

**Effect:** Frontend gets updated balance immediately

## Verification Commands

```bash
# Check all instances
./check_backend_instances.sh

# Test database connection
python3 backend/test_db_connection.py

# Diagnose balance consistency
python3 backend/diagnose_balance_issue.py 9000000001

# Deploy to all instances
./deploy_to_all_asg_instances.sh
```

## Expected Results

✅ Balance consistent across all refreshes
✅ No flickering
✅ Payout response includes `wallet_balance`
✅ All instances show same code version

## If Something Goes Wrong

### Database connection failed
→ Check `FIX_DATABASE_CONNECTION_ERROR.md`

### Balance still flickering
→ Not all instances updated. Check each instance.

### Service won't start
→ Check logs: `sudo journalctl -u moneyone-backend -n 100`

## Performance Impact

- Row lock duration: 5-10ms
- User-perceived delay: None
- Throughput: No change

## FAQ

**Q: Will this affect PayIn/PayOut?**
A: No, it makes them MORE reliable by preventing race conditions.

**Q: Do I need sticky sessions forever?**
A: No, just during deployment. But it doesn't hurt to keep it.

**Q: What if I have 10 instances?**
A: Deploy to all 10. Use the automated script: `deploy_to_all_asg_instances.sh`

## Support

Full documentation:
- `COMPLETE_BALANCE_FIX_GUIDE.md` - Complete guide
- `ROW_LOCKING_IMPACT_ANALYSIS.md` - Performance analysis
- `ENABLE_STICKY_SESSIONS_ALB.md` - Sticky sessions guide
