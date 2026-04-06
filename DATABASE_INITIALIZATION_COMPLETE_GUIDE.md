# OrchPay Database Initialization - Complete Guide

This guide provides step-by-step instructions to initialize your OrchPay database on AWS RDS.

---

## Prerequisites

- RDS MySQL instance created and running
- EC2 instance with backend code deployed
- MySQL client installed on EC2
- Backend virtual environment activated
- RDS endpoint, username, and password ready

---

## Quick Start (TL;DR)

```bash
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate
python migrate_database.py
python create_orchpay_admin_user.py
```

---

## Detailed Step-by-Step Guide

### Step 1: Verify Database Connection

```bash
# SSH to your EC2 instance
ssh -i orchpay-key.pem ubuntu@<BASTION_IP>
ssh ubuntu@<EC2_PRIVATE_IP>

# Navigate to backend directory
cd /var/www/orchpay/orchpay/backend

# Activate virtual environment
source venv/bin/activate

# Test database connection
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p
```

**Expected Output:**
```
Enter password: [enter your RDS password]
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 123
Server version: 8.0.35

mysql>
```

**Test Commands:**
```sql
-- Show all databases
SHOW DATABASES;

-- Select your database
USE moneyone_db;

-- Show existing tables (if any)
SHOW TABLES;

-- Exit
exit
```

---

### Step 2: Run Database Migration

The migration script will:
1. Create a backup of existing data
2. Create all required tables
3. Add missing columns to existing tables
4. Create indexes for performance
5. Preserve all existing data

**Run Migration:**
```bash
python migrate_database.py
```

**Expected Output:**
```
============================================================
OrchPay Database Migration
============================================================

✓ Connected to database: moneyone_db

📦 Creating database backup: backup_moneyone_db_20260406_103000.sql
✓ Backup created successfully (1234567 bytes)

🔨 Creating tables...
✓ Creating table: admin_users
✓ Creating table: admin_activity_logs
✓ Creating table: commercial_schemes
✓ Creating table: commercial_charges
✓ Creating table: merchants
✓ Creating table: merchant_documents
✓ Creating table: merchant_ip_whitelist
✓ Creating table: merchant_callbacks
✓ Creating table: merchant_banks
✓ Creating table: admin_banks
✓ Creating table: payin_transactions
✓ Creating table: merchant_wallet
✓ Creating table: wallet_transactions
✓ Creating table: callback_logs
✓ Creating table: payu_webhook_config
✓ Creating table: payu_webhook_logs
✓ Creating table: payu_tokens
✓ Creating table: service_routing
✓ Creating table: payout_transactions
✓ Creating table: fund_requests
✓ Creating table: merchant_unsettled_wallet
✓ Creating table: admin_wallet
✓ Creating table: admin_wallet_transactions

📊 Creating indexes...
✓ Creating index: payin_transactions.idx_merchant_id
✓ Creating index: payin_transactions.idx_status
✓ Creating index: payin_transactions.idx_created_at
✓ Creating index: payout_transactions.idx_merchant_id
✓ Creating index: payout_transactions.idx_status
✓ Creating index: payout_transactions.idx_created_at
✓ Creating index: payout_transactions.idx_reference_id
✓ Creating index: payout_transactions.idx_order_id
✓ Creating index: wallet_transactions.idx_merchant_id
✓ Creating index: wallet_transactions.idx_created_at
✓ Creating index: callback_logs.idx_txn_id
✓ Creating index: payu_webhook_logs.idx_event_type
✓ Creating index: payu_webhook_logs.idx_merchant_ref_id
✓ Creating index: payu_webhook_logs.idx_created_at
✓ Creating index: fund_requests.idx_merchant_id
✓ Creating index: fund_requests.idx_status
✓ Creating index: admin_wallet_transactions.idx_admin_id
✓ Creating index: admin_wallet_transactions.idx_wallet_type
✓ Creating index: admin_wallet_transactions.idx_created_at

🔍 Verifying schema...
✓ Total tables: 23
  - admin_users: 0 rows
  - admin_activity_logs: 0 rows
  - commercial_schemes: 0 rows
  - commercial_charges: 0 rows
  - merchants: 0 rows
  - merchant_documents: 0 rows
  - merchant_ip_whitelist: 0 rows
  - merchant_callbacks: 0 rows
  - merchant_banks: 0 rows
  - admin_banks: 0 rows
  - payin_transactions: 0 rows
  - merchant_wallet: 0 rows
  - wallet_transactions: 0 rows
  - callback_logs: 0 rows
  - payu_webhook_config: 0 rows
  - payu_webhook_logs: 0 rows
  - payu_tokens: 0 rows
  - service_routing: 0 rows
  - payout_transactions: 0 rows
  - fund_requests: 0 rows
  - merchant_unsettled_wallet: 0 rows
  - admin_wallet: 0 rows
  - admin_wallet_transactions: 0 rows

============================================================
✓ Migration completed successfully!
============================================================

📦 Backup file: backup_moneyone_db_20260406_103000.sql
   Keep this file safe in case you need to restore.

✓ Database connection closed
```

**Migration Options:**

```bash
# Dry run (see what will be done without making changes)
python migrate_database.py --dry-run

# Backup only (don't run migration)
python migrate_database.py --backup-only
```

---

### Step 3: Verify Tables Created

```bash
# List all tables
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "USE moneyone_db; SHOW TABLES;"
```

**Expected Output:**
```
+---------------------------+
| Tables_in_moneyone_db     |
+---------------------------+
| admin_activity_logs       |
| admin_banks               |
| admin_users               |
| admin_wallet              |
| admin_wallet_transactions |
| callback_logs             |
| commercial_charges        |
| commercial_schemes        |
| fund_requests             |
| merchant_banks            |
| merchant_callbacks        |
| merchant_documents        |
| merchant_ip_whitelist     |
| merchant_unsettled_wallet |
| merchant_wallet           |
| merchants                 |
| payin_transactions        |
| payout_transactions       |
| payu_tokens               |
| payu_webhook_config       |
| payu_webhook_logs         |
| service_routing           |
| wallet_transactions       |
+---------------------------+
23 rows in set (0.05 sec)
```

**Check Table Structure:**
```bash
# Check admin_users table structure
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "DESCRIBE moneyone_db.admin_users;"
```

---

### Step 4: Create Admin User

```bash
python create_orchpay_admin_user.py
```

**Expected Output:**
```
==================================================
OrchPay Admin User Creation
==================================================

Database: moneyone_db
Host: orchpay-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com
User: admin

Creating admin user...
Connecting to database: moneyone_db at orchpay-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com...

✅ Admin user created successfully!

==================================================
Admin User Details:
==================================================
ID: 1
Name: OrchPay Admin
Email: admin@orchpay.in
Password: Admin@123
Role: super_admin
Status: active
==================================================

📝 Login Instructions:
1. Go to: https://admin.orchpay.in
2. Email: admin@orchpay.in
3. Password: Admin@123

⚠️  IMPORTANT: Change this password after first login!

Database connection closed.

✅ Setup completed successfully!
```

**If Admin Already Exists:**
```
⚠️  Admin user already exists!
Email: admin@orchpay.in
ID: 1
Name: OrchPay Admin

Do you want to reset the password? (yes/no): yes

✅ Password reset successfully!

Login Credentials:
Email: admin@orchpay.in
Password: Admin@123

Database connection closed.
```

---

### Step 5: Verify Admin User

```bash
# Check admin user in database
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SELECT id, admin_id, is_active, created_at FROM moneyone_db.admin_users;"
```

**Expected Output:**
```
+----+--------------------+-----------+---------------------+
| id | admin_id           | is_active | created_at          |
+----+--------------------+-----------+---------------------+
|  1 | admin@orchpay.in   |         1 | 2026-04-06 10:30:00 |
+----+--------------------+-----------+---------------------+
```

---

### Step 6: Initialize Admin Wallet

```bash
# Create admin wallet entry
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p moneyone_db << 'EOF'
INSERT INTO admin_wallet (admin_id, main_balance, unsettled_balance, last_updated)
VALUES ('admin@orchpay.in', 0.00, 0.00, NOW())
ON DUPLICATE KEY UPDATE 
    admin_id = VALUES(admin_id),
    last_updated = NOW();
EOF
```

**Verify Wallet Created:**
```bash
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SELECT * FROM moneyone_db.admin_wallet;"
```

---

### Step 7: Test Backend API

```bash
# Check if backend is running
sudo systemctl status orchpay-api

# Test health endpoint
curl http://localhost:5000/api/health

# Expected: {"status": "healthy"}
```

---

## Database Schema Overview

### Core Tables

**Admin Tables:**
- `admin_users` - Admin user accounts
- `admin_activity_logs` - Admin activity tracking
- `admin_banks` - Admin bank accounts
- `admin_wallet` - Admin wallet balances
- `admin_wallet_transactions` - Admin wallet transaction history

**Merchant Tables:**
- `merchants` - Merchant accounts
- `merchant_documents` - Merchant KYC documents
- `merchant_ip_whitelist` - IP whitelist for merchants
- `merchant_callbacks` - Callback URLs
- `merchant_banks` - Merchant bank accounts
- `merchant_wallet` - Merchant settled wallet
- `merchant_unsettled_wallet` - Merchant unsettled wallet

**Transaction Tables:**
- `payin_transactions` - Pay-in transactions
- `payout_transactions` - Payout transactions
- `wallet_transactions` - Wallet transaction history
- `callback_logs` - Callback attempt logs

**Configuration Tables:**
- `commercial_schemes` - Pricing schemes
- `commercial_charges` - Charge configurations
- `service_routing` - Payment gateway routing
- `fund_requests` - Fund request management

**Payment Gateway Tables:**
- `payu_webhook_config` - PayU webhook configuration
- `payu_webhook_logs` - PayU webhook logs
- `payu_tokens` - PayU authentication tokens

---

## Troubleshooting

### Issue: Cannot Connect to Database

**Check 1: RDS Endpoint**
```bash
# Verify RDS endpoint in .env file
cat /var/www/orchpay/orchpay/backend/.env | grep DB_HOST
```

**Check 2: Security Group**
```bash
# Test connection
telnet <RDS_ENDPOINT> 3306
# Should connect successfully
```

**Check 3: Credentials**
```bash
# Test with mysql client
mysql -h <RDS_ENDPOINT> -u admin -p
```

### Issue: Migration Script Fails

**Check Python Dependencies:**
```bash
pip list | grep -i mysql
# Should show: PyMySQL
```

**Install if missing:**
```bash
pip install PyMySQL
```

**Check Database Permissions:**
```sql
SHOW GRANTS FOR 'admin'@'%';
```

Should have:
- CREATE
- ALTER
- INSERT
- UPDATE
- DELETE
- SELECT
- INDEX

### Issue: Admin User Creation Fails

**Check if table exists:**
```bash
mysql -h <RDS_ENDPOINT> -u admin -p -e "DESCRIBE moneyone_db.admin_users;"
```

**Check Python dependencies:**
```bash
pip list | grep -i werkzeug
# Should show: Werkzeug
```

**Manual admin creation:**
```bash
# Generate password hash
python3 << 'EOF'
from werkzeug.security import generate_password_hash
print(generate_password_hash('Admin@123'))
EOF

# Copy the hash and insert manually
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db << 'EOF'
INSERT INTO admin_users (admin_id, password_hash, is_active, created_at)
VALUES ('admin@orchpay.in', 'PASTE_HASH_HERE', 1, NOW());
EOF
```

### Issue: Tables Already Exist

The migration script is safe to run multiple times. It will:
- Skip existing tables
- Only add missing columns
- Only create missing indexes

```bash
# Safe to run again
python migrate_database.py
```

### Issue: Need to Reset Database

**⚠️ WARNING: This will delete all data!**

```bash
# Backup first!
mysqldump -h <RDS_ENDPOINT> -u admin -p moneyone_db > backup_before_reset.sql

# Drop all tables
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db << 'EOF'
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS admin_users, admin_activity_logs, admin_banks, admin_wallet, 
admin_wallet_transactions, commercial_schemes, commercial_charges, merchants, 
merchant_documents, merchant_ip_whitelist, merchant_callbacks, merchant_banks, 
merchant_wallet, merchant_unsettled_wallet, payin_transactions, payout_transactions, 
wallet_transactions, callback_logs, fund_requests, service_routing, payu_webhook_config, 
payu_webhook_logs, payu_tokens;
SET FOREIGN_KEY_CHECKS = 1;
EOF

# Run migration again
python migrate_database.py

# Create admin user
python create_orchpay_admin_user.py
```

---

## Backup and Restore

### Create Manual Backup

```bash
# Full database backup
mysqldump -h <RDS_ENDPOINT> -u admin -p moneyone_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup specific tables
mysqldump -h <RDS_ENDPOINT> -u admin -p moneyone_db admin_users merchants > backup_users.sql

# Backup with compression
mysqldump -h <RDS_ENDPOINT> -u admin -p moneyone_db | gzip > backup.sql.gz
```

### Restore from Backup

```bash
# Restore full database
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db < backup_20260406_103000.sql

# Restore from compressed backup
gunzip < backup.sql.gz | mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db
```

### Automated Backups

RDS automatically creates daily backups with 7-day retention (configured during RDS setup).

To restore from RDS backup:
1. Go to RDS Console
2. Select your database
3. Actions → Restore to point in time
4. Choose date/time
5. Create new database instance

---

## Post-Initialization Checklist

- [ ] Database migration completed successfully
- [ ] All 23 tables created
- [ ] Indexes created for performance
- [ ] Admin user created (admin@orchpay.in)
- [ ] Admin wallet initialized
- [ ] Backend API can connect to database
- [ ] Health endpoint returns success
- [ ] Backup file saved securely
- [ ] Admin login tested on https://admin.orchpay.in

---

## Next Steps

1. **Test Admin Login**
   - Go to https://admin.orchpay.in
   - Login with admin@orchpay.in / Admin@123
   - Change password immediately

2. **Create Commercial Schemes**
   - Define pricing for merchants
   - Set up charge configurations

3. **Create Test Merchant**
   - Add a test merchant account
   - Configure payment gateway routing
   - Test payin/payout flows

4. **Configure Payment Gateways**
   - Add PayU credentials
   - Configure other payment partners
   - Set up routing rules

5. **Monitor Database**
   - Set up CloudWatch alarms
   - Monitor slow queries
   - Review transaction logs

---

**Last Updated:** 2026-04-06  
**Database Version:** MySQL 8.0.35  
**Environment:** AWS RDS Production
