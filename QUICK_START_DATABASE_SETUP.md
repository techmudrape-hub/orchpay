# Quick Start: Database Setup

## 1-Minute Setup

```bash
# SSH to EC2
ssh -i orchpay-key.pem ubuntu@<BASTION_IP>
ssh ubuntu@<EC2_PRIVATE_IP>

# Navigate and activate
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate

# Run migration
python migrate_database.py

# Create admin
python create_orchpay_admin_user.py
```

## Login

```
URL: https://admin.orchpay.in
Email: admin@orchpay.in
Password: Admin@123
```

⚠️ Change password after first login!

## Verify

```bash
# Check tables
mysql -h <RDS_ENDPOINT> -u admin -p -e "USE moneyone_db; SHOW TABLES;"

# Check admin
mysql -h <RDS_ENDPOINT> -u admin -p -e "SELECT * FROM moneyone_db.admin_users;"

# Test API
curl http://localhost:5000/api/health
```

## Troubleshooting

**Can't connect to database:**
```bash
# Check .env file
cat .env | grep DB_

# Test connection
mysql -h <RDS_ENDPOINT> -u admin -p
```

**Migration fails:**
```bash
# Install dependencies
pip install PyMySQL

# Try again
python migrate_database.py
```

**Admin creation fails:**
```bash
# Check table exists
mysql -h <RDS_ENDPOINT> -u admin -p -e "DESCRIBE moneyone_db.admin_users;"

# Run migration first
python migrate_database.py

# Then create admin
python create_orchpay_admin_user.py
```

## Full Documentation

- Complete Guide: `DATABASE_INITIALIZATION_COMPLETE_GUIDE.md`
- AWS Deployment: `AWS_EC2_RDS_COMPLETE_DEPLOYMENT_GUIDE.md`
- Admin Credentials: `ORCHPAY_ADMIN_CREDENTIALS.md`
