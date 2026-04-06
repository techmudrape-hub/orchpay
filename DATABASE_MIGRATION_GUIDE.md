# OrchPay Database Migration Guide

## Overview
This guide provides step-by-step instructions for safely migrating your OrchPay database schema.

## Prerequisites

1. **Python 3.7+** installed
2. **MySQL/MariaDB** running
3. **Required Python packages**:
   ```bash
   pip install pymysql
   ```
4. **Database credentials** configured in `backend/.env`
5. **Backup tools**: `mysqldump` available in PATH

## Migration Script Features

✅ **Safe Migration**
- Creates automatic backup before any changes
- Preserves all existing data
- Only adds missing tables/columns/indexes
- Never drops or modifies existing data

✅ **Dry Run Mode**
- Test migration without making changes
- See what would be done

✅ **Backup Only Mode**
- Create backup without running migration

## Quick Start

### 1. Test Migration (Dry Run)
```bash
cd backend
python migrate_database.py --dry-run
```

This shows what would be done without making any changes.

### 2. Create Backup Only
```bash
python migrate_database.py --backup-only
```

Creates a backup file: `backup_orchpay_db_YYYYMMDD_HHMMSS.sql`

### 3. Run Full Migration
```bash
python migrate_database.py
```

This will:
1. Create a backup
2. Create missing tables
3. Add missing indexes
4. Verify the schema

## Migration Process Details

### Step 1: Backup Creation
The script automatically creates a backup using `mysqldump`:
```bash
mysqldump -h HOST -u USER -pPASSWORD DATABASE > backup_orchpay_db_TIMESTAMP.sql
```

**Backup file location**: Same directory as the script

### Step 2: Table Creation
Creates all required tables if they don't exist:
- `admin_users` - Admin authentication
- `admin_activity_logs` - Admin activity tracking
- `commercial_schemes` - Pricing schemes
- `commercial_charges` - Charge configurations
- `merchants` - Merchant accounts
- `merchant_documents` - Document storage paths
- `merchant_ip_whitelist` - IP security
- `merchant_callbacks` - Callback URLs
- `merchant_banks` - Bank accounts
- `admin_banks` - Admin bank accounts
- `payin_transactions` - Payment collections
- `payout_transactions` - Payment disbursements
- `merchant_wallet` - Merchant balances
- `merchant_unsettled_wallet` - Unsettled balances
- `wallet_transactions` - Transaction history
- `admin_wallet` - Admin wallet
- `admin_wallet_transactions` - Admin transactions
- `callback_logs` - Callback history
- `payu_webhook_config` - PayU webhook config
- `payu_webhook_logs` - PayU webhook logs
- `payu_tokens` - PayU authentication tokens
- `service_routing` - Service routing rules
- `fund_requests` - Fund request management

### Step 3: Index Creation
Creates performance indexes on:
- Transaction tables (merchant_id, status, created_at)
- Wallet tables (merchant_id, created_at)
- Callback logs (txn_id)
- Webhook logs (event_type, merchant_ref_id, created_at)
- Fund requests (merchant_id, status)

### Step 4: Schema Verification
Verifies:
- All tables exist
- Row counts for each table
- Database integrity

## Troubleshooting

### Issue: "Database connection error"
**Solution**: Check your `.env` file:
```env
DB_HOST=localhost
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=orchpay_db
```

### Issue: "Backup failed"
**Solutions**:
1. Ensure `mysqldump` is in your PATH
2. Check database credentials
3. Verify disk space
4. Check write permissions

### Issue: "Foreign key constraint fails"
**Solution**: The script creates tables in the correct order. If you see this error:
1. Check if you have existing data with invalid references
2. Run with `--dry-run` to see what would be created
3. Manually fix data integrity issues

### Issue: "Table already exists"
**This is normal!** The script only creates missing tables. Existing tables are preserved.

## Manual Backup (Alternative)

If the automatic backup fails, create a manual backup:

```bash
# Full database backup
mysqldump -h localhost -u root -p orchpay_db > backup_manual.sql

# Backup specific tables
mysqldump -h localhost -u root -p orchpay_db \
  admin_users merchants payin_transactions payout_transactions \
  > backup_critical_tables.sql

# Backup with compression
mysqldump -h localhost -u root -p orchpay_db | gzip > backup.sql.gz
```

## Restore from Backup

If you need to restore from backup:

```bash
# Restore full database
mysql -h localhost -u root -p orchpay_db < backup_orchpay_db_20240327_120000.sql

# Restore from compressed backup
gunzip < backup.sql.gz | mysql -h localhost -u root -p orchpay_db
```

## Post-Migration Verification

### 1. Check Table Count
```sql
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'orchpay_db';
```
Expected: 28 tables

### 2. Verify Critical Tables
```sql
-- Check admin users
SELECT COUNT(*) FROM admin_users;

-- Check merchants
SELECT COUNT(*) FROM merchants;

-- Check transactions
SELECT COUNT(*) FROM payin_transactions;
SELECT COUNT(*) FROM payout_transactions;

-- Check wallets
SELECT COUNT(*) FROM merchant_wallet;
SELECT COUNT(*) FROM admin_wallet;
```

### 3. Test Application
1. Start the backend server
2. Login to admin portal
3. Check dashboard loads
4. Verify merchant list
5. Test transaction queries

## Database Schema Overview

### Core Tables
- **Authentication**: `admin_users`, `merchants`
- **Transactions**: `payin_transactions`, `payout_transactions`
- **Wallets**: `merchant_wallet`, `merchant_unsettled_wallet`, `admin_wallet`
- **Configuration**: `commercial_schemes`, `commercial_charges`, `service_routing`

### Supporting Tables
- **Documents**: `merchant_documents`
- **Security**: `merchant_ip_whitelist`
- **Integration**: `merchant_callbacks`, `callback_logs`
- **PayU**: `payu_webhook_config`, `payu_webhook_logs`, `payu_tokens`
- **Banking**: `merchant_banks`, `admin_banks`
- **Funds**: `fund_requests`
- **Audit**: `admin_activity_logs`, `wallet_transactions`, `admin_wallet_transactions`

## Performance Optimization

The migration creates indexes on:
- High-frequency query columns (merchant_id, status)
- Date range queries (created_at)
- Transaction lookups (txn_id, reference_id, order_id)

## Security Considerations

1. **Backup Security**: Store backups in a secure location
2. **Credentials**: Never commit `.env` files
3. **Access Control**: Limit database user permissions
4. **Encryption**: Consider encrypting backup files

## Migration Checklist

- [ ] Review current database structure
- [ ] Test migration with `--dry-run`
- [ ] Create backup with `--backup-only`
- [ ] Verify backup file exists and has data
- [ ] Run full migration
- [ ] Verify schema with SQL queries
- [ ] Test application functionality
- [ ] Store backup in secure location
- [ ] Document any custom changes
- [ ] Update team on migration completion

## Support

If you encounter issues:
1. Check the backup file was created
2. Review error messages carefully
3. Run with `--dry-run` to diagnose
4. Check database logs
5. Verify credentials and permissions

## Advanced Usage

### Custom Migration
If you need to add custom tables or columns, edit `migrate_database.py`:

```python
# Add to create_tables() method
'my_custom_table': """
    CREATE TABLE IF NOT EXISTS my_custom_table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
"""
```

### Rollback
To rollback to a previous state:
```bash
mysql -h localhost -u root -p orchpay_db < backup_orchpay_db_TIMESTAMP.sql
```

## Best Practices

1. **Always backup before migration**
2. **Test in development first**
3. **Run during low-traffic periods**
4. **Keep multiple backup copies**
5. **Document custom changes**
6. **Monitor application after migration**
7. **Keep migration scripts version controlled**

## Conclusion

The migration script is designed to be safe and non-destructive. It only adds missing components and never removes existing data. Always keep backups and test in a development environment first.
