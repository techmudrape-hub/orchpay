# AWS EC2 Deployment Guide - MoneyOne Project

## Project Overview
- **Admin Panel**: admin.moneyone.co.in
- **Merchant Portal**: partner.moneyone.co.in
- **API Backend**: api.orchpay.in
- **Project Location**: /var/www/moneyone/moneyone

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [EC2 Instance Setup](#ec2-instance-setup)
3. [Domain Configuration](#domain-configuration)
4. [Server Initial Setup](#server-initial-setup)
5. [Install Dependencies](#install-dependencies)
6. [Project Deployment](#project-deployment)
7. [Database Setup](#database-setup)
8. [Backend Configuration](#backend-configuration)
9. [Frontend Build & Deployment](#frontend-build--deployment)
10. [Nginx Configuration](#nginx-configuration)
11. [SSL Certificate Setup](#ssl-certificate-setup)
12. [Process Management](#process-management)
13. [Security Hardening](#security-hardening)
14. [Monitoring & Maintenance](#monitoring--maintenance)
15. [Troubleshooting](#troubleshooting)

---

## 1. Prerequisites

### Required Items
- AWS Account with billing enabled
- Domain names registered (moneyone.co.in)
- SSH key pair for EC2 access
- Basic knowledge of Linux commands

### Local Machine Requirements
- SSH client (PuTTY for Windows, Terminal for Mac/Linux)
- Git installed
- Code editor (VS Code recommended)

---

## 2. EC2 Instance Setup

### Step 2.1: Launch EC2 Instance

1. **Login to AWS Console**
   - Navigate to EC2 Dashboard
   - Click "Launch Instance"

2. **Configure Instance**
   ```
   Name: moneyone-production
   AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
   Architecture: 64-bit (x86)
   Instance Type: t3.medium (minimum) or t3.large (recommended)
   ```

3. **Key Pair**
   - Create new key pair: `moneyone-production.pem`
   - Download and save securely
   - Set permissions: `chmod 400 moneyone-production.pem`

4. **Network Settings**
   - VPC: Default or create new
   - Auto-assign public IP: Enable
   - Security Group: Create new "moneyone-sg"

5. **Security Group Rules**
   ```
   Type            Protocol    Port Range    Source          Description
   SSH             TCP         22            Your IP         SSH access
   HTTP            TCP         80            0.0.0.0/0       HTTP traffic
   HTTPS           TCP         443           0.0.0.0/0       HTTPS traffic
   Custom TCP      TCP         5000          0.0.0.0/0       Backend API (temporary)
   MySQL           TCP         3306          Security Group  Database (internal only)
   ```

6. **Storage Configuration**
   ```
   Root Volume: 30 GB gp3 SSD (minimum)
   Additional Volume: 50 GB gp3 SSD (for database and logs)
   ```

7. **Launch Instance**
   - Review and launch
   - Note down the Public IP address

### Step 2.2: Connect to EC2 Instance

**For Linux/Mac:**
```bash
chmod 400 moneyone-production.pem
ssh -i moneyone-production.pem ubuntu@<EC2_PUBLIC_IP>
```

**For Windows (using PuTTY):**
1. Convert .pem to .ppk using PuTTYgen
2. Use PuTTY with the .ppk file

---

## 3. Domain Configuration

### Step 3.1: Configure DNS Records

Login to your domain registrar (GoDaddy, Namecheap, etc.) and add these A records:

```
Type    Name        Value               TTL
A       @           <EC2_PUBLIC_IP>     600
A       admin       <EC2_PUBLIC_IP>     600
A       partner     <EC2_PUBLIC_IP>     600
A       api         <EC2_PUBLIC_IP>     600
```

### Step 3.2: Verify DNS Propagation

Wait 5-10 minutes, then verify:
```bash
nslookup admin.moneyone.co.in
nslookup partner.moneyone.co.in
nslookup api.orchpay.in
```

---

## 4. Server Initial Setup

### Step 4.1: Update System

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

Wait 2 minutes, then reconnect via SSH.

### Step 4.2: Set Timezone

```bash
sudo timedatectl set-timezone Asia/Kolkata
timedatectl
```

### Step 4.3: Create Project Directory Structure

```bash
sudo mkdir -p /var/www/moneyone
sudo chown -R ubuntu:ubuntu /var/www/moneyone
cd /var/www/moneyone
```

---

## 5. Install Dependencies

### Step 5.1: Install Python 3.11

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3 python3-venv python3-dev python3-pip
```

### Step 5.2: Install MySQL

```bash
sudo apt install -y mysql-server mysql-client
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Step 5.3: Install Node.js & npm

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version
```

### Step 5.4: Install Nginx

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Step 5.5: Install Additional Tools

```bash
sudo apt install -y git curl wget unzip build-essential libmysqlclient-dev pkg-config
```

---

## 6. Project Deployment

### Step 6.1: Clone Repository

```bash
cd /var/www/moneyone
git clone <YOUR_REPOSITORY_URL> moneyone
cd moneyone
```

**If using private repository:**
```bash
# Generate SSH key on server
ssh-keygen -t ed25519 -C "server@moneyone.co.in"
cat ~/.ssh/id_ed25519.pub
# Add this key to your GitHub/GitLab account
```

### Step 6.2: Verify Project Structure

```bash
ls -la
# Should see: backend/, moneyone_admin/, moneyone_client/
```

---

## 7. Database Setup

### Step 7.1: Secure MySQL Installation

```bash
sudo mysql_secure_installation
```

Follow the prompts:
- Set root password: YES (choose a strong password)
- Remove anonymous users: YES
- Disallow root login remotely: YES
- Remove test database: YES
- Reload privilege tables: YES

### Step 7.2: Create Database and User

```bash
sudo mysql -u root -p
```

In MySQL prompt:
```sql
-- Create database
CREATE DATABASE moneyone_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'moneyone_user'@'localhost' IDENTIFIED BY 'your_secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON moneyone_db.* TO 'moneyone_user'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Verify
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'moneyone_user';

-- Exit
EXIT;
```

### Step 7.3: Import Database File

**Locate your database file in the project:**
```bash
cd /var/www/moneyone/moneyone
find . -name "*.sql" -o -name "*.sql.gz"
```

**If database file is .sql:**
```bash
mysql -u moneyone_user -p moneyone_db < /var/www/moneyone/moneyone/path/to/your/database.sql
```

**If database file is .sql.gz (compressed):**
```bash
gunzip < /var/www/moneyone/moneyone/path/to/your/database.sql.gz | mysql -u moneyone_user -p moneyone_db
```

**Example (adjust path to your actual database file):**
```bash
# If your database file is in backend folder
mysql -u moneyone_user -p moneyone_db < /var/www/moneyone/moneyone/backend/moneyone_db.sql
```

### Step 7.4: Verify Database Import

```bash
mysql -u moneyone_user -p moneyone_db
```

In MySQL prompt:
```sql
-- Show all tables
SHOW TABLES;

-- Check table structure (example)
DESCRIBE users;
DESCRIBE merchants;
DESCRIBE transactions;

-- Count records (example)
SELECT COUNT(*) FROM users;

-- Exit
EXIT;
```

### Step 7.5: Configure MySQL for Production

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add/modify these settings:
```ini
[mysqld]
# Bind to localhost only
bind-address = 127.0.0.1

# Performance settings
max_connections = 200
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Timezone
default-time-zone = '+05:30'
```

Restart MySQL:
```bash
sudo systemctl restart mysql
```

---

## 8. Backend Configuration

### Step 8.1: Create Python Virtual Environment

```bash
cd /var/www/moneyone/moneyone/backend
python3.11 -m venv venv
source venv/bin/activate
```

### Step 8.2: Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**If requirements.txt doesn't exist, install manually:**
```bash
pip install flask flask-cors flask-jwt-extended mysqlclient pymysql python-dotenv requests gunicorn
```

### Step 8.3: Configure Environment Variables

```bash
cd /var/www/moneyone/moneyone/backend
nano .env
```
# Generate SECRET_KEY
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_hex(32))"

# Generate JWT_SECRET_KEY
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_hex(32))"

Add the following configuration:
```env
# Database Configuration
DATABASE_URL=mysql://moneyone_user:Moneyone?123@localhost:3306/moneyone_db
DB_HOST=localhost
DB_PORT=3306
DB_NAME=moneyone_db
DB_USER=moneyone_user
DB_PASSWORD=Moneyone?123


# PayU Configuration
PAYU_MERCHANT_KEY=832Oh4
PAYU_MERCHANT_SALT=IF0g1MHTu5aPG9jTt8jplpBhrqrGacRb
PAYU_BASE_URL=https://secure.payu.in
PAYU_TEST_MODE=False

# PayU Payout Configuration
PAYU_PAYOUT_CLIENT_ID=6f8bb4951e030d4d7349e64a144a534778673585f86039617c167166e9154f7e
PAYU_PAYOUT_USERNAME=payouttest5@mailinator.com
PAYU_PAYOUT_PASSWORD=Tester@123
PAYU_PAYOUT_MERCHANT_ID=1111123
PAYU_PAYOUT_BASE_URL=https://uatoneapi.payu.in
PAYU_PAYOUT_AUTH_URL=https://uat-accounts.payu.in


# Flask Configuration
FLASK_APP=app.py
FLASK_ENV=production
SECRET_KEY=b0024d4d42ddea7ee7ab7c6ecd053efa6de1a08a2f0c2b30beb968ad34c31aab

# JWT Configuration
JWT_SECRET_KEY=30166a47d2bcd6523fb7cfd04b676517c013c03b00cb3c352be18194e4b64591
JWT_ACCESS_TOKEN_EXPIRES=3600

# API URLs
API_BASE_URL=https://api.orchpay.in
ADMIN_URL=https://admin.moneyone.co.in
PARTNER_URL=https://partner.moneyone.co.in

# CORS Origins
CORS_ORIGINS=https://admin.moneyone.co.in,https://partner.moneyone.co.in
CORS_ALLOW_CREDENTIALS=True


MUDRAPE_BASE_URL=https://agentmudrape.com
MUDRAPE_API_KEY=pk_2580642bf7f031983a0390755ee52b9e
MUDRAPE_API_SECRET=sk_af9c19bef57d63c100b01b174258ee3693761a6bb679d1676b6930dcb4985688
MUDRAPE_USER_ID=cmlujaiqv00tw01s6up9o7376
MUDRAPE_MERCHANT_MID=APIPA100015
MUDRAPE_MERCHANT_EMAIL=indrajeet@mudrape.com
MUDRAPE_MERCHANT_SECRET=sk_af9c19bef57d63c100b01b174258ee3693761a6bb679d1676b6930dcb4985688

# Email Configuration (if applicable)
SMTP_HOST=smtp.hostinger.com
SMTP_PORT=587
SMTP_USER=support@moneyone.co.in
SMTP_PASSWORD=Moneyone@12345

# Other Settings
TIMEZONE=Asia/Kolkata
LOG_LEVEL=INFO

# Uploads Configuration
UPLOADS_BASE_URL=https://api.orchpay.in/uploads
UPLOADS_FOLDER=uploads
MAX_UPLOAD_SIZE=5242880
ALLOWED_EXTENSIONS=jpg,jpeg,png,pdf
```

**Generate secure keys:**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Step 8.4: Verify Database Connection

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python -c "import pymysql; conn = pymysql.connect(host='localhost', user='moneyone_user', password='your_secure_password_here', database='moneyone_db'); print('Database connection successful!'); conn.close()"
```

**Note:** Since you're importing an existing database, skip the database initialization scripts. If you need to create additional users or data, run:
```bash
# Only if needed
python create_admin_user.py
```

### Step 8.5: Test Backend Locally

```bash
python app.py
```

Open another terminal and test:
```bash
curl http://localhost:5000/health
```

Stop the test server (Ctrl+C).

---

## 9. Frontend Build & Deployment

### Step 9.1: Build Admin Panel

```bash
cd /var/www/moneyone/moneyone/moneyone_admin
```

Create `.env` file:
```bash
nano .env
```

Add:
```env
VITE_API_BASE_URL=https://api.orchpay.in
```

Install and build:
```bash
npm install
npm run build
```

### Step 9.2: Build Merchant Portal

```bash
cd /var/www/moneyone/moneyone/moneyone_client
```

Create `.env` file:
```bash
nano .env
```

Add:
```env
VITE_API_BASE_URL=https://api.orchpay.in
```

Install and build:
```bash
npm install
npm run build
```

### Step 9.3: Verify Build Output

```bash
ls -la /var/www/moneyone/moneyone/moneyone_admin/dist
ls -la /var/www/moneyone/moneyone/moneyone_client/dist
```

---

## 10. Nginx Configuration

### Step 10.1: Remove Default Configuration

```bash
sudo rm /etc/nginx/sites-enabled/default
```

### Step 10.2: Create Admin Panel Configuration

```bash
sudo nano /etc/nginx/sites-available/admin.moneyone.co.in
```

Add:
```nginx
server {
    listen 80;
    server_name admin.moneyone.co.in;

    root /var/www/moneyone/moneyone/moneyone_admin/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    client_max_body_size 10M;
}
```

### Step 10.3: Create Merchant Portal Configuration

```bash
sudo nano /etc/nginx/sites-available/partner.moneyone.co.in
```

Add:
```nginx
server {
    listen 80;
    server_name partner.moneyone.co.in;

    root /var/www/moneyone/moneyone/moneyone_client/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    client_max_body_size 10M;
}
```

### Step 10.4: Create API Backend Configuration

```bash
sudo nano /etc/nginx/sites-available/api.orchpay.in
```

Add:
```nginx
server {
    listen 80;
    server_name api.orchpay.in;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    client_max_body_size 10M;
}
```

### Step 10.5: Enable Sites

```bash
sudo ln -s /etc/nginx/sites-available/admin.moneyone.co.in /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/partner.moneyone.co.in /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.orchpay.in /etc/nginx/sites-enabled/
```

### Step 10.6: Test and Reload Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 11. SSL Certificate Setup

### Step 11.1: Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Step 11.2: Obtain SSL Certificates

```bash
sudo certbot --nginx -d admin.moneyone.co.in
sudo certbot --nginx -d partner.moneyone.co.in
sudo certbot --nginx -d api.orchpay.in
```

Follow prompts:
- Enter email address
- Agree to terms
- Choose to redirect HTTP to HTTPS (option 2)

### Step 11.3: Verify Auto-Renewal

```bash
sudo certbot renew --dry-run
```

### Step 11.4: Test HTTPS

Visit in browser:
- https://admin.moneyone.co.in
- https://partner.moneyone.co.in
- https://api.orchpay.in/health

---

## 12. Process Management

### Step 12.1: Create Gunicorn Service

```bash
sudo nano /etc/systemd/system/moneyone-api.service
```

Add:
```ini
[Unit]
Description=MoneyOne API Backend
After=network.target mysql.service

[Service]
Type=notify
User=ubuntu
Group=ubuntu
WorkingDirectory=/var/www/moneyone/moneyone/backend
Environment="PATH=/var/www/moneyone/moneyone/backend/venv/bin"
ExecStart=/var/www/moneyone/moneyone/backend/venv/bin/gunicorn \
    --workers 4 \
    --worker-class sync \
    --bind 127.0.0.1:5000 \
    --timeout 120 \
    --access-logfile /var/log/moneyone/access.log \
    --error-logfile /var/log/moneyone/error.log \
    --log-level info \
    app:app

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Step 12.2: Create Log Directory

```bash
sudo mkdir -p /var/log/moneyone
sudo chown ubuntu:ubuntu /var/log/moneyone
```

### Step 12.3: Start and Enable Service

```bash
sudo systemctl daemon-reload
sudo systemctl start moneyone-api
sudo systemctl enable moneyone-api
sudo systemctl status moneyone-api
```

### Step 12.4: View Logs

```bash
# Real-time logs
sudo journalctl -u moneyone-api -f

# Application logs
tail -f /var/log/moneyone/error.log
tail -f /var/log/moneyone/access.log
```

---

## 13. Security Hardening

### Step 13.1: Configure Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

### Step 13.2: Secure MySQL

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Ensure only local connections:
```ini
[mysqld]
bind-address = 127.0.0.1
skip-networking = 0
```

Disable remote root login:
```bash
sudo mysql -u root -p
```

```sql
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EXIT;
```

```bash
sudo systemctl restart mysql
```

### Step 13.3: Set File Permissions

```bash
cd /var/www/moneyone/moneyone
chmod 600 backend/.env
chmod 600 moneyone_admin/.env
chmod 600 moneyone_client/.env
```

### Step 13.4: Disable Root Login

```bash
sudo nano /etc/ssh/sshd_config
```

Set:
```
PermitRootLogin no
PasswordAuthentication no
```

```bash
sudo systemctl restart sshd
```

### Step 13.5: Install Fail2Ban

```bash
sudo apt install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

---

## 14. Monitoring & Maintenance

### Step 14.1: Setup Log Rotation

```bash
sudo nano /etc/logrotate.d/moneyone
```

Add:
```
/var/log/moneyone/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 ubuntu ubuntu
    sharedscripts
    postrotate
        systemctl reload moneyone-api > /dev/null 2>&1 || true
    endscript
}
```

### Step 14.2: Create Backup Script

```bash
nano /home/ubuntu/backup-moneyone.sh
```

Add:
```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_USER="moneyone_user"
DB_PASS="your_secure_password_here"
DB_NAME="moneyone_db"

mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup application files
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /var/www/moneyone/moneyone

# Keep only last 7 days
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

Make executable:
```bash
chmod +x /home/ubuntu/backup-moneyone.sh
```

### Step 14.3: Schedule Backups

```bash
crontab -e
```

Add:
```
0 2 * * * /home/ubuntu/backup-moneyone.sh >> /var/log/moneyone/backup.log 2>&1
```

### Step 14.4: Monitor System Resources

```bash
# Install htop
sudo apt install -y htop

# Check resources
htop
df -h
free -h
```

---

## 15. Troubleshooting

### Common Issues and Solutions

#### Issue 1: Nginx 502 Bad Gateway

**Check backend service:**
```bash
sudo systemctl status moneyone-api
sudo journalctl -u moneyone-api -n 50
```

**Restart service:**
```bash
sudo systemctl restart moneyone-api
```

#### Issue 2: Database Connection Error

**Check MySQL:**
```bash
sudo systemctl status mysql
mysql -u root -p -e "SELECT version();"
```

**Test connection:**
```bash
mysql -u moneyone_user -p moneyone_db
```

**Check MySQL error logs:**
```bash
sudo tail -f /var/log/mysql/error.log
```

#### Issue 3: Frontend Not Loading

**Check Nginx:**
```bash
sudo nginx -t
sudo systemctl status nginx
```

**Check file permissions:**
```bash
ls -la /var/www/moneyone/moneyone/moneyone_admin/dist
ls -la /var/www/moneyone/moneyone/moneyone_client/dist
```

#### Issue 4: SSL Certificate Issues

**Renew certificates:**
```bash
sudo certbot renew
sudo systemctl reload nginx
```

#### Issue 5: High Memory Usage

**Check processes:**
```bash
ps aux --sort=-%mem | head -10
```

**Restart services:**
```bash
sudo systemctl restart moneyone-api
sudo systemctl restart nginx
```

### Useful Commands

```bash
# View all services
sudo systemctl list-units --type=service

# Check disk usage
du -sh /var/www/moneyone/*

# Check network connections
sudo netstat -tulpn | grep LISTEN

# View system logs
sudo journalctl -xe

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check application logs
tail -f /var/log/moneyone/error.log
```

---

## Post-Deployment Checklist

- [ ] EC2 instance running and accessible
- [ ] DNS records configured and propagated
- [ ] All dependencies installed
- [ ] Database created and initialized
- [ ] Backend service running
- [ ] Frontend applications built
- [ ] Nginx configured for all domains
- [ ] SSL certificates installed
- [ ] Firewall configured
- [ ] Backup script scheduled
- [ ] All URLs accessible via HTTPS
- [ ] Admin panel login working
- [ ] Merchant portal login working
- [ ] API endpoints responding
- [ ] Logs being generated properly

---

## Quick Reference

### Service Management
```bash
# Start/Stop/Restart backend
sudo systemctl start moneyone-api
sudo systemctl stop moneyone-api
sudo systemctl restart moneyone-api

# Nginx
sudo systemctl reload nginx
sudo systemctl restart nginx

# MySQL
sudo systemctl restart mysql
```

### Log Locations
```
Application Logs: /var/log/moneyone/
Nginx Logs: /var/log/nginx/
System Logs: /var/log/syslog
Service Logs: sudo journalctl -u moneyone-api
```

### Important Paths
```
Project Root: /var/www/moneyone/moneyone
Backend: /var/www/moneyone/moneyone/backend
Admin: /var/www/moneyone/moneyone/moneyone_admin
Merchant: /var/www/moneyone/moneyone/moneyone_client
Nginx Config: /etc/nginx/sites-available/
SSL Certs: /etc/letsencrypt/live/
```

---

## Support & Resources

- AWS EC2 Documentation: https://docs.aws.amazon.com/ec2/
- Nginx Documentation: https://nginx.org/en/docs/
- Let's Encrypt: https://letsencrypt.org/docs/
- MySQL Documentation: https://dev.mysql.com/doc/
- Flask Documentation: https://flask.palletsprojects.com/

---

**Deployment Guide Version**: 1.0  
**Last Updated**: February 2026  
**Project**: MoneyOne Payment Gateway
