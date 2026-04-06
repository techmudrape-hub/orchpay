# OrchPay Admin Credentials

## Default Admin User

**Login URL:** https://admin.orchpay.in

**Credentials:**
```
Email: admin@orchpay.in
Password: Admin@123
```

## Creating/Resetting Admin User

To create or reset the admin user, run this script on your server:

```bash
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate
python create_orchpay_admin_user.py
```

The script will:
- Create a new admin user if one doesn't exist
- Ask if you want to reset the password if the user already exists
- Display the login credentials

## Security Best Practices

⚠️ **IMPORTANT:**
1. Change the default password immediately after first login
2. Use a strong password with:
   - At least 12 characters
   - Mix of uppercase and lowercase letters
   - Numbers and special characters
3. Enable two-factor authentication (if available)
4. Never share admin credentials
5. Never commit credentials to version control
6. Use different passwords for different environments (dev/staging/production)

## Changing Admin Password

### Method 1: Through Admin Panel
1. Login to https://admin.orchpay.in
2. Go to Profile/Settings
3. Change password
4. Logout and login with new password

### Method 2: Through Database (Emergency)
```bash
# Connect to your server
ssh -i orchpay-key.pem ubuntu@<BASTION_IP>
ssh ubuntu@<EC2_PRIVATE_IP>

# Run the script
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate
python create_orchpay_admin_user.py

# Choose "yes" when asked to reset password
```

### Method 3: Direct Database Update
```bash
# Connect to RDS
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db

# Generate password hash in Python
python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('YourNewPassword'))"

# Update in database
UPDATE admin_users SET password = '<HASHED_PASSWORD>' WHERE email = 'admin@orchpay.in';
```

## Admin User Details

| Field | Value |
|-------|-------|
| Name | OrchPay Admin |
| Email | admin@orchpay.in |
| Role | super_admin |
| Status | active |
| Default Password | Admin@123 |

## Troubleshooting

### Cannot Login
1. Verify the admin user exists:
   ```bash
   mysql -h <RDS_ENDPOINT> -u admin -p -e "SELECT * FROM moneyone_db.admin_users WHERE email='admin@orchpay.in';"
   ```

2. Check if password is correct by resetting it:
   ```bash
   python create_orchpay_admin_user.py
   ```

3. Verify backend API is running:
   ```bash
   curl https://api.orchpay.in/api/health
   ```

4. Check backend logs:
   ```bash
   sudo journalctl -u orchpay-api -f
   tail -f /var/www/orchpay/orchpay/backend/logs/error.log
   ```

### Forgot Password
Run the password reset script:
```bash
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate
python create_orchpay_admin_user.py
```

Choose "yes" when prompted to reset the password.

## Additional Admin Users

To create additional admin users, you can:

1. Login as super admin
2. Go to Admin Management section
3. Add new admin users with appropriate roles

Or modify the script to create users with different credentials.

---

**Last Updated:** 2026-04-06
**Environment:** Production (AWS)
