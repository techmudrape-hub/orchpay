# OrchPay Database Setup & Backend Run Guide

## Prerequisites

Before starting, ensure you have:
- MySQL server running
- Python 3.8+ installed
- Fresh database `orchpay_db` created

## Step 1: Update Database Configuration

Update your `backend/.env` file with the new database name:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=orchpay_db
```

**Important:** Replace `your_mysql_password` with your actual MySQL root password.

## Step 2: Install Python Dependencies

Open terminal in the `backend` directory and run:

```bash
cd backend
pip install -r requirements.txt
```

This will install all required packages:
- Flask (web framework)
- PyMySQL (MySQL connector)
- bcrypt (password hashing)
- Flask-JWT-Extended (authentication)
- Flask-CORS (cross-origin support)
- And other dependencies

## Step 3: Create Database Tables

Run the complete database setup script:

```bash
python setup_database_complete.py
```

This script will:
1. Connect to MySQL server
2. Create/verify the `orchpay_db` database
3. Create all 25 required tables:
   - admin_users
   - admin_activity_logs
   - commercial_schemes
   - commercial_charges
   - merchants
   - merchant_documents
   - merchant_ip_whitelist
   - merchant_callbacks
   - merchant_banks
   - admin_banks
   - payin_transactions
   - payout_transactions
   - merchant_wallet
   - merchant_unsettled_wallet
   - admin_wallet
   - wallet_transactions
   - admin_wallet_transactions
   - fund_requests
   - service_routing
   - callback_logs
   - payu_webhook_config
   - payu_webhook_logs
   - payu_tokens
4. Insert initial data (admin user, default scheme, test merchant)

**Note:** The script will ask for confirmation before proceeding. Type `yes` to continue.

## Step 4: Verify Database Setup

After the script completes, you can verify the tables were created:

```bash
mysql -u root -p orchpay_db -e "SHOW TABLES;"
```

You should see all 25 tables listed.

## Step 5: Run the Backend Server

### Option A: Development Mode (Flask built-in server)

```bash
python app.py
```

The server will start on `http://localhost:5000`

### Option B: Production Mode (with Gunicorn)

If you have gunicorn installed:

```bash
gunicorn -c gunicorn_config.py app:app
```

## Step 6: Test the Backend

Test if the backend is running:

```bash
curl http://localhost:5000/api/admin/captcha
```

You should receive a JSON response with captcha data.

## Default Admin Credentials

After setup, you'll receive default admin credentials. Typically:
- **Admin ID:** Will be displayed after setup
- **Password:** Will be displayed after setup

**Important:** Change the admin password immediately after first login!

## Common Issues & Solutions

### Issue 1: Database Connection Failed
**Solution:** 
- Verify MySQL is running: `mysql -u root -p`
- Check credentials in `.env` file
- Ensure user has necessary privileges

### Issue 2: Module Not Found Error
**Solution:**
```bash
pip install -r requirements.txt
```

### Issue 3: Port 5000 Already in Use
**Solution:**
- Stop the process using port 5000
- Or modify `app.py` to use a different port

### Issue 4: Permission Denied on MySQL
**Solution:**
```sql
GRANT ALL PRIVILEGES ON orchpay_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

## API Endpoints

Once running, the backend provides these main endpoints:

- `POST /api/admin/login` - Admin login
- `GET /api/admin/verify` - Verify JWT token
- `POST /api/admin/logout` - Admin logout
- `GET /api/admin/activity-logs` - Get activity logs
- And many more for payin/payout operations

## Next Steps

1. Start the admin frontend (`orchpay_admin`)
2. Start the client frontend (`orchpay_client`)
3. Login to admin dashboard
4. Configure payment gateway credentials
5. Create merchants and test transactions

## File Structure Reference

```
backend/
├── app.py                          # Main Flask application
├── config.py                       # Configuration loader
├── database_pooled.py              # Database connection pool
├── setup_database_complete.py      # Database setup script
├── create_complete_database.py     # Table creation logic
├── insert_initial_data.py          # Initial data insertion
├── requirements.txt                # Python dependencies
├── .env                           # Environment configuration
└── [other route and service files]
```

## Support

If you encounter any issues:
1. Check the console output for error messages
2. Verify all prerequisites are met
3. Ensure `.env` file is properly configured
4. Check MySQL error logs if database issues persist

---

**Created:** $(date)
**Database:** orchpay_db
**Backend Port:** 5000 (default)
