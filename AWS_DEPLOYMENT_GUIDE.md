# MoneyOne AWS EC2 Deployment Guide

## Complete A-Z Deployment Guide for Production

This guide covers the complete deployment of MoneyOne application on AWS EC2 with three subdomains:
- **Admin Dashboard**: admin.moneyone.co.in
- **Merchant Dashboard**: partner.moneyone.co.in
- **Backend API**: api.orchpay.in

**Project Location**: `/var/www/moneyone/moneyone`

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS EC2 Setup](#aws-ec2-setup)
3. [Domain Configuration](#domain-configuration)
4. [Server Initial Setup](#server-initial-setup)
5. [Install Required Software](#install-required-software)
6. [Database Setup](#database-setup)
7. [Project Deployment](#project-deployment)
8. [Backend API Configuration](#backend-api-configuration)
9. [Frontend Build & Deployment](#frontend-build--deployment)
10. [Nginx Configuration](#nginx-configuration)
11. [SSL Certificate Setup](#ssl-certificate-setup)
12. [Process Management](#process-management)
13. [Security Hardening](#security-hardening)
14. [Monitoring & Maintenance](#monitoring--maintenance)
15. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:
- AWS Account with billing enabled
- Domain name (moneyone.co.in) with access to DNS settings
- SSH client (PuTTY for Windows, Terminal for Mac/Linux)
- Basic knowledge of Linux commands
- Your project code ready for deployment

---


## PART 1: AWS EC2 Setup

### Step 1: Launch EC2 Instance

1. **Login to AWS Console**
   - Go to https://console.aws.amazon.com/
   - Navigate to EC2 Dashboard

2. **Launch Instance**
   - Click "Launch Instance" button
   - **Name**: MoneyOne-Production
   
3. **Choose AMI (Amazon Machine Image)**
   - Select: **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
   - Architecture: 64-bit (x86)

4. **Choose Instance Type**
   - Recommended: **t3.medium** (2 vCPU, 4 GB RAM)
   - Minimum: **t3.small** (2 vCPU, 2 GB RAM)
   - For production with high traffic: **t3.large** or higher

5. **Key Pair (Login)**
   - Click "Create new key pair"
   - Key pair name: `moneyone-production`
   - Key pair type: RSA
   - Private key format: .pem (for Mac/Linux) or .ppk (for Windows/PuTTY)
   - Click "Create key pair" and **SAVE THE FILE SECURELY**

6. **Network Settings**
   - VPC: Default VPC
   - Auto-assign public IP: Enable
   - Firewall (Security Groups): Create new security group
     - Security group name: `moneyone-sg`
     - Description: Security group for MoneyOne application

7. **Configure Security Group Rules**
   Add the following inbound rules:
   
   | Type | Protocol | Port Range | Source | Description |
   |------|----------|------------|--------|-------------|
   | SSH | TCP | 22 | My IP | SSH access |
   | HTTP | TCP | 80 | 0.0.0.0/0 | HTTP traffic |
   | HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS traffic |
   | Custom TCP | TCP | 5000 | 0.0.0.0/0 | Flask API (temporary) |
   | MySQL/Aurora | TCP | 3306 | Security Group ID | MySQL (internal only) |

8. **Configure Storage**
   - Root volume: 30 GB gp3 (General Purpose SSD)
   - For production: 50-100 GB recommended

9. **Advanced Details** (Optional but recommended)
   - Enable detailed monitoring
   - Termination protection: Enable

10. **Review and Launch**
    - Review all settings
    - Click "Launch Instance"
    - Wait for instance state to become "Running"

11. **Note Your Instance Details**
    - Public IPv4 address: `XX.XX.XX.XX`
    - Public IPv4 DNS: `ec2-XX-XX-XX-XX.compute-1.amazonaws.com`



---

## PART 2: Domain Configuration

### Step 2: Configure DNS Records

1. **Login to Your Domain Registrar**
   - Go to your domain provider (GoDaddy, Namecheap, etc.)
   - Navigate to DNS Management for moneyone.co.in

2. **Add A Records**
   Point all three subdomains to your EC2 public IP:

   | Type | Name | Value | TTL |
   |------|------|-------|-----|
   | A | admin | XX.XX.XX.XX | 600 |
   | A | partner | XX.XX.XX.XX | 600 |
   | A | api | XX.XX.XX.XX | 600 |

   Replace `XX.XX.XX.XX` with your EC2 instance public IP

3. **Verify DNS Propagation**
   Wait 5-10 minutes, then test:
   ```bash
   # On your local machine
   nslookup admin.moneyone.co.in
   nslookup partner.moneyone.co.in
   nslookup api.orchpay.in
   ```

   All should return your EC2 IP address

---

## PART 3: Connect to EC2 Instance

### Step 3: SSH Connection

**For Mac/Linux:**
```bash
# Set correct permissions for key file
chmod 400 moneyone-production.pem

# Connect to EC2
ssh -i moneyone-production.pem ubuntu@XX.XX.XX.XX
```

**For Windows (using PuTTY):**
1. Open PuTTYgen
2. Load your .ppk file (or convert .pem to .ppk)
3. Open PuTTY
4. Host Name: ubuntu@XX.XX.XX.XX
5. Connection > SSH > Auth > Browse and select .ppk file
6. Click "Open"

### Step 4: Initial Server Setup

Once connected, run these commands:

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Set timezone to IST
sudo timedatectl set-timezone Asia/Kolkata

# Verify timezone
timedatectl

# Create swap file (recommended for t3.small/medium)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify swap
free -h
```



---

## PART 4: Install Required Software

### Step 5: Install Python and Dependencies

```bash
# Install Python 3.11
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev -y

# Install pip
sudo apt install python3-pip -y

# Verify installation
python3.11 --version
pip3 --version
```

### Step 6: Install Node.js and npm

```bash
# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

### Step 7: Install MySQL Server

```bash
# Install MySQL 8.0
sudo apt install mysql-server -y

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation
sudo mysql_secure_installation
```

**MySQL Secure Installation Prompts:**
- Validate Password Component: Yes
- Password Validation Policy: 2 (Strong)
- Set root password: [Choose a strong password]
- Remove anonymous users: Yes
- Disallow root login remotely: Yes
- Remove test database: Yes
- Reload privilege tables: Yes

### Step 8: Install Nginx

```bash
# Install Nginx
sudo apt install nginx -y

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# Test: Open browser and visit http://XX.XX.XX.XX
# You should see "Welcome to nginx" page
```

### Step 9: Install Additional Tools

```bash
# Install Git
sudo apt install git -y

# Install build essentials
sudo apt install build-essential -y

# Install certbot for SSL
sudo apt install certbot python3-certbot-nginx -y

# Install supervisor for process management
sudo apt install supervisor -y
sudo systemctl enable supervisor
sudo systemctl start supervisor
```



---

## PART 5: Database Setup

### Step 10: Configure MySQL Database

```bash
# Login to MySQL as root
sudo mysql -u root -p
```

**Inside MySQL prompt, run:**

```sql
-- Create database
CREATE DATABASE moneyone_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create database user
CREATE USER 'moneyone_user'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';

-- Grant privileges
GRANT ALL PRIVILEGES ON moneyone_db.* TO 'moneyone_user'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Verify
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'moneyone_user';

-- Exit MySQL
EXIT;
```

**Test connection:**
```bash
mysql -u moneyone_user -p moneyone_db
# Enter password when prompted
# If successful, you'll see MySQL prompt
EXIT;
```

### Step 11: Configure MySQL for Production

```bash
# Edit MySQL configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

**Add/modify these settings:**
```ini
[mysqld]
# Bind to localhost only (security)
bind-address = 127.0.0.1

# Performance tuning
max_connections = 200
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
query_cache_size = 0
query_cache_type = 0

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Timezone
default-time-zone = '+05:30'
```

**Restart MySQL:**
```bash
sudo systemctl restart mysql
```



---

## PART 6: Project Deployment

### Step 12: Create Project Directory Structure

```bash
# Create directory structure
sudo mkdir -p /var/www/moneyone
sudo chown -R ubuntu:ubuntu /var/www/moneyone
cd /var/www/moneyone

# Create project directory
mkdir moneyone
cd moneyone
```

### Step 13: Upload Project Files

**Option 1: Using Git (Recommended)**

```bash
# If your project is on GitHub/GitLab
cd /var/www/moneyone/moneyone
git clone https://github.com/yourusername/moneyone.git .

# Or if using private repo
git clone https://your-username:your-token@github.com/yourusername/moneyone.git .
```

**Option 2: Using SCP (from your local machine)**

```bash
# From your local machine (Mac/Linux)
cd /path/to/your/moneyone/project
scp -i moneyone-production.pem -r * ubuntu@XX.XX.XX.XX:/var/www/moneyone/moneyone/

# For Windows, use WinSCP or FileZilla
```

**Option 3: Using rsync (Recommended for updates)**

```bash
# From your local machine
rsync -avz -e "ssh -i moneyone-production.pem" \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '__pycache__' \
  --exclude '.git' \
  /path/to/local/moneyone/ \
  ubuntu@XX.XX.XX.XX:/var/www/moneyone/moneyone/
```

### Step 14: Verify Project Structure

```bash
cd /var/www/moneyone/moneyone
ls -la

# You should see:
# backend/
# moneyone_admin/
# moneyone_client/
# and other files
```



---

## PART 7: Backend API Configuration

### Step 15: Setup Python Virtual Environment

```bash
cd /var/www/moneyone/moneyone/backend

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

### Step 16: Configure Backend Environment Variables

```bash
cd /var/www/moneyone/moneyone/backend

# Create production .env file
nano .env
```

**Production .env configuration:**

```env
# Database Configuration
DB_HOST=localhost
DB_USER=moneyone_user
DB_PASSWORD=YourStrongPassword123!
DB_NAME=moneyone_db

# JWT Configuration
JWT_SECRET_KEY=your-super-secret-production-jwt-key-change-this-now-12345
FLASK_ENV=production

# PayU Configuration (Use production credentials)
PAYU_MERCHANT_KEY=your_production_merchant_key
PAYU_MERCHANT_SALT=your_production_merchant_salt
PAYU_BASE_URL=https://secure.payu.in
PAYU_TEST_MODE=False

# PayU Payout Configuration (Use production credentials)
PAYU_PAYOUT_CLIENT_ID=your_production_client_id
PAYU_PAYOUT_USERNAME=your_production_username
PAYU_PAYOUT_PASSWORD=your_production_password
PAYU_PAYOUT_MERCHANT_ID=your_production_merchant_id
PAYU_PAYOUT_BASE_URL=https://oneapi.payu.in
PAYU_PAYOUT_AUTH_URL=https://accounts.payu.in

# SMTP Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=noreply@moneyone.co.in
SMTP_FROM_NAME=MoneyOne
SMTP_USE_TLS=True

# CORS Configuration
CORS_ORIGINS=https://admin.moneyone.co.in,https://partner.moneyone.co.in
CORS_ALLOW_CREDENTIALS=True

# Uploads Configuration
UPLOADS_BASE_URL=https://api.orchpay.in/uploads
UPLOADS_FOLDER=uploads
MAX_UPLOAD_SIZE=5242880
ALLOWED_EXTENSIONS=jpg,jpeg,png,pdf
```

**Save and exit** (Ctrl+X, Y, Enter)

### Step 17: Initialize Database

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate

# Run database setup script
python setup_complete_database.py

# Create admin user
python create_admin_user.py

# Verify database
python verify_database.py
```

### Step 18: Test Backend API

```bash
# Test run Flask app
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python app.py

# You should see:
# * Running on http://127.0.0.1:5000
```

**Open another terminal and test:**
```bash
curl http://localhost:5000/api/admin/captcha
# Should return JSON response
```

**Stop the test server** (Ctrl+C)



---

## PART 8: Frontend Build & Deployment

### Step 19: Build Admin Dashboard

```bash
cd /var/www/moneyone/moneyone/moneyone_admin

# Create production .env
nano .env
```

**Admin .env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

**Build:**
```bash
# Install dependencies
npm install

# Build for production
npm run build

# Verify dist folder
ls -la dist/
```

### Step 20: Build Merchant Dashboard

```bash
cd /var/www/moneyone/moneyone/moneyone_client

# Create production .env
nano .env
```

**Client .env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

**Build:**
```bash
# Install dependencies
npm install

# Build for production
npm run build

# Verify dist folder
ls -la dist/
```

### Step 21: Setup Web Root Directories

```bash
# Create web directories
sudo mkdir -p /var/www/admin.moneyone.co.in
sudo mkdir -p /var/www/partner.moneyone.co.in

# Copy built files
sudo cp -r /var/www/moneyone/moneyone/moneyone_admin/dist/* /var/www/admin.moneyone.co.in/
sudo cp -r /var/www/moneyone/moneyone/moneyone_client/dist/* /var/www/partner.moneyone.co.in/

# Set permissions
sudo chown -R www-data:www-data /var/www/admin.moneyone.co.in
sudo chown -R www-data:www-data /var/www/partner.moneyone.co.in
sudo chmod -R 755 /var/www/admin.moneyone.co.in
sudo chmod -R 755 /var/www/partner.moneyone.co.in

# Verify
ls -la /var/www/admin.moneyone.co.in/
ls -la /var/www/partner.moneyone.co.in/
```



---

## PART 9: Nginx Configuration

### Step 22: Configure Nginx for Admin Dashboard

```bash
sudo nano /etc/nginx/sites-available/admin.moneyone.co.in
```

**Admin Nginx config:**
```nginx
server {
    listen 80;
    server_name admin.moneyone.co.in;
    
    root /var/www/admin.moneyone.co.in;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Logs
    access_log /var/log/nginx/admin.moneyone.co.in.access.log;
    error_log /var/log/nginx/admin.moneyone.co.in.error.log;
}
```

### Step 23: Configure Nginx for Merchant Dashboard

```bash
sudo nano /etc/nginx/sites-available/partner.moneyone.co.in
```

**Merchant Nginx config:**
```nginx
server {
    listen 80;
    server_name partner.moneyone.co.in;
    
    root /var/www/partner.moneyone.co.in;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Logs
    access_log /var/log/nginx/partner.moneyone.co.in.access.log;
    error_log /var/log/nginx/partner.moneyone.co.in.error.log;
}
```



### Step 24: Configure Nginx for Backend API

```bash
sudo nano /etc/nginx/sites-available/api.orchpay.in
```

**API Nginx config:**
```nginx
upstream flask_backend {
    server 127.0.0.1:5000;
}

server {
    listen 80;
    server_name api.orchpay.in;
    
    client_max_body_size 10M;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        proxy_pass http://flask_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers (handled by Flask, but backup)
        add_header Access-Control-Allow-Origin "https://admin.moneyone.co.in, https://partner.moneyone.co.in" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
        add_header Access-Control-Allow-Credentials "true" always;
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            return 204;
        }
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Serve uploaded files
    location /uploads/ {
        alias /var/www/moneyone/moneyone/backend/uploads/;
        expires 1y;
        add_header Cache-Control "public";
    }
    
    # Logs
    access_log /var/log/nginx/api.orchpay.in.access.log;
    error_log /var/log/nginx/api.orchpay.in.error.log;
}
```

### Step 25: Enable Sites and Test Nginx

```bash
# Enable sites
sudo ln -s /etc/nginx/sites-available/admin.moneyone.co.in /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/partner.moneyone.co.in /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.orchpay.in /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# If test passes, reload Nginx
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx
```



---

## PART 10: SSL Certificate Setup (Let's Encrypt)

### Step 26: Install SSL Certificates

**Important:** Ensure DNS records are properly configured and propagated before running certbot.

```bash
# Install certificates for all three domains
sudo certbot --nginx -d admin.moneyone.co.in -d partner.moneyone.co.in -d api.orchpay.in
```

**Certbot prompts:**
1. Enter email address: your-email@example.com
2. Agree to terms: Yes (Y)
3. Share email with EFF: Your choice (Y/N)
4. Redirect HTTP to HTTPS: Yes (2)

**Verify SSL installation:**
```bash
# Check certificate status
sudo certbot certificates

# Test auto-renewal
sudo certbot renew --dry-run
```

**Auto-renewal is configured automatically**. Certificates will renew 30 days before expiration.

### Step 27: Verify HTTPS Access

Open browser and test:
- https://admin.moneyone.co.in (should show admin dashboard)
- https://partner.moneyone.co.in (should show merchant dashboard)
- https://api.orchpay.in/api/admin/captcha (should return JSON)

All should have valid SSL certificates (green padlock).



---

## PART 11: Process Management with Supervisor

### Step 28: Configure Gunicorn for Flask

```bash
# Install Gunicorn in virtual environment
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install gunicorn

# Test Gunicorn
gunicorn --bind 127.0.0.1:5000 app:app
# Press Ctrl+C to stop
```

### Step 29: Create Supervisor Configuration

```bash
sudo nano /etc/supervisor/conf.d/moneyone-api.conf
```

**Supervisor config:**
```ini
[program:moneyone-api]
command=/var/www/moneyone/moneyone/backend/venv/bin/gunicorn --workers 4 --bind 127.0.0.1:5000 --timeout 120 --access-logfile /var/log/moneyone/api-access.log --error-logfile /var/log/moneyone/api-error.log app:app
directory=/var/www/moneyone/moneyone/backend
user=ubuntu
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/moneyone/api-stderr.log
stdout_logfile=/var/log/moneyone/api-stdout.log
environment=PATH="/var/www/moneyone/moneyone/backend/venv/bin"
```

### Step 30: Start Backend Service

```bash
# Create log directory
sudo mkdir -p /var/log/moneyone
sudo chown ubuntu:ubuntu /var/log/moneyone

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update

# Start the service
sudo supervisorctl start moneyone-api

# Check status
sudo supervisorctl status moneyone-api

# View logs
sudo tail -f /var/log/moneyone/api-stdout.log
```

**Useful supervisor commands:**
```bash
# Stop service
sudo supervisorctl stop moneyone-api

# Restart service
sudo supervisorctl restart moneyone-api

# View all services
sudo supervisorctl status

# Reload configuration
sudo supervisorctl reload
```



---

## PART 12: Security Hardening

### Step 31: Configure Firewall (UFW)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (IMPORTANT: Do this first!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status verbose

# Deny direct access to Flask port from outside
sudo ufw deny 5000/tcp
```

### Step 32: Secure SSH Access

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

**Modify these settings:**
```
# Disable root login
PermitRootLogin no

# Disable password authentication (use key only)
PasswordAuthentication no

# Allow only specific user
AllowUsers ubuntu

# Change default port (optional but recommended)
# Port 2222
```

**Restart SSH:**
```bash
sudo systemctl restart sshd
```

### Step 33: Setup Fail2Ban

```bash
# Install Fail2Ban
sudo apt install fail2ban -y

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

**Configure Fail2Ban:**
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
```

**Start Fail2Ban:**
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client status
```

### Step 34: Secure MySQL

```bash
# Edit MySQL config
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

**Ensure these settings:**
```ini
[mysqld]
# Bind to localhost only
bind-address = 127.0.0.1

# Disable remote root login
skip-networking = 0
```

**Restart MySQL:**
```bash
sudo systemctl restart mysql
```

### Step 35: Setup Automatic Security Updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades -y

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

**Enable security updates:**
```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
```



---

## PART 13: Monitoring & Maintenance

### Step 36: Setup Log Rotation

```bash
# Create logrotate config for application logs
sudo nano /etc/logrotate.d/moneyone
```

**Logrotate config:**
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
        supervisorctl restart moneyone-api > /dev/null 2>&1 || true
    endscript
}

/var/log/nginx/*.moneyone.co.in.*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        nginx -s reload > /dev/null 2>&1 || true
    endscript
}
```

### Step 37: Setup Monitoring Script

```bash
# Create monitoring script
nano ~/monitor.sh
```

**Monitoring script:**
```bash
#!/bin/bash

echo "=== MoneyOne System Status ==="
echo "Date: $(date)"
echo ""

echo "=== Disk Usage ==="
df -h | grep -E '^/dev/'
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== CPU Load ==="
uptime
echo ""

echo "=== Nginx Status ==="
sudo systemctl status nginx --no-pager | head -5
echo ""

echo "=== MySQL Status ==="
sudo systemctl status mysql --no-pager | head -5
echo ""

echo "=== Backend API Status ==="
sudo supervisorctl status moneyone-api
echo ""

echo "=== Recent API Errors ==="
sudo tail -20 /var/log/moneyone/api-error.log
echo ""

echo "=== Nginx Error Logs ==="
sudo tail -20 /var/log/nginx/api.orchpay.in.error.log
```

**Make executable:**
```bash
chmod +x ~/monitor.sh
```

**Run monitoring:**
```bash
~/monitor.sh
```

### Step 38: Setup Backup Script

```bash
# Create backup script
nano ~/backup.sh
```

**Backup script:**
```bash
#!/bin/bash

BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="moneyone_db"
DB_USER="moneyone_user"
DB_PASS="YourStrongPassword123!"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# Backup uploaded files
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz /var/www/moneyone/moneyone/backend/uploads/

# Backup environment files
tar -czf $BACKUP_DIR/env_backup_$DATE.tar.gz /var/www/moneyone/moneyone/backend/.env

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
ls -lh $BACKUP_DIR
```

**Make executable and test:**
```bash
chmod +x ~/backup.sh
~/backup.sh
```

**Setup daily backup cron:**
```bash
crontab -e
```

**Add this line:**
```
0 2 * * * /home/ubuntu/backup.sh >> /home/ubuntu/backup.log 2>&1
```



---

## PART 14: Deployment Verification Checklist

### Step 39: Complete Verification

**1. DNS Verification:**
```bash
nslookup admin.moneyone.co.in
nslookup partner.moneyone.co.in
nslookup api.orchpay.in
```

**2. SSL Certificate Verification:**
```bash
curl -I https://admin.moneyone.co.in
curl -I https://partner.moneyone.co.in
curl -I https://api.orchpay.in
```

**3. Backend API Test:**
```bash
# Test captcha endpoint
curl https://api.orchpay.in/api/admin/captcha

# Should return JSON with success: true
```

**4. Frontend Access:**
- Open https://admin.moneyone.co.in in browser
- Open https://partner.moneyone.co.in in browser
- Both should load without errors

**5. Login Test:**
- Try logging into admin dashboard
- Try logging into merchant dashboard
- Verify API calls work (check browser console)

**6. Service Status:**
```bash
# Check all services
sudo systemctl status nginx
sudo systemctl status mysql
sudo supervisorctl status moneyone-api
```

**7. Log Check:**
```bash
# Check for errors
sudo tail -50 /var/log/nginx/api.orchpay.in.error.log
sudo tail -50 /var/log/moneyone/api-error.log
```

**8. Security Check:**
```bash
# Verify firewall
sudo ufw status

# Verify fail2ban
sudo fail2ban-client status
```



---

## PART 15: Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: 502 Bad Gateway Error

**Symptoms:** Nginx shows 502 error when accessing API

**Solutions:**
```bash
# Check if backend is running
sudo supervisorctl status moneyone-api

# If stopped, start it
sudo supervisorctl start moneyone-api

# Check backend logs
sudo tail -50 /var/log/moneyone/api-error.log

# Check if port 5000 is listening
sudo netstat -tlnp | grep 5000

# Restart backend
sudo supervisorctl restart moneyone-api
```

#### Issue 2: Database Connection Error

**Symptoms:** Backend logs show "Can't connect to MySQL server"

**Solutions:**
```bash
# Check MySQL status
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql

# Test database connection
mysql -u moneyone_user -p moneyone_db

# Check MySQL logs
sudo tail -50 /var/log/mysql/error.log

# Verify credentials in .env file
cat /var/www/moneyone/moneyone/backend/.env | grep DB_
```

#### Issue 3: Frontend Shows Blank Page

**Symptoms:** Browser shows blank page or loading forever

**Solutions:**
```bash
# Check browser console for errors
# Usually API URL mismatch

# Verify .env files
cat /var/www/admin.moneyone.co.in/.env
cat /var/www/partner.moneyone.co.in/.env

# Rebuild frontend with correct API URL
cd /var/www/moneyone/moneyone/moneyone_admin
nano .env  # Set VITE_API_BASE_URL=https://api.orchpay.in/api
npm run build
sudo cp -r dist/* /var/www/admin.moneyone.co.in/

# Clear browser cache and reload
```

#### Issue 4: CORS Errors

**Symptoms:** Browser console shows CORS policy errors

**Solutions:**
```bash
# Check backend .env CORS settings
cat /var/www/moneyone/moneyone/backend/.env | grep CORS

# Should be:
# CORS_ORIGINS=https://admin.moneyone.co.in,https://partner.moneyone.co.in

# Restart backend
sudo supervisorctl restart moneyone-api

# Check Nginx CORS headers
sudo nano /etc/nginx/sites-available/api.orchpay.in
# Verify CORS headers are present

# Reload Nginx
sudo nginx -t && sudo systemctl reload nginx
```

#### Issue 5: SSL Certificate Issues

**Symptoms:** Browser shows "Not Secure" or certificate errors

**Solutions:**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Force renew if needed
sudo certbot renew --force-renewal

# Check Nginx SSL configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

#### Issue 6: File Upload Fails

**Symptoms:** Document upload returns error

**Solutions:**
```bash
# Check uploads directory exists
ls -la /var/www/moneyone/moneyone/backend/uploads/

# Create if missing
mkdir -p /var/www/moneyone/moneyone/backend/uploads/merchant_documents

# Set correct permissions
sudo chown -R ubuntu:ubuntu /var/www/moneyone/moneyone/backend/uploads/
chmod -R 755 /var/www/moneyone/moneyone/backend/uploads/

# Check Nginx client_max_body_size
sudo nano /etc/nginx/sites-available/api.orchpay.in
# Should have: client_max_body_size 10M;

# Reload Nginx
sudo systemctl reload nginx
```

#### Issue 7: High Memory Usage

**Symptoms:** Server becomes slow or unresponsive

**Solutions:**
```bash
# Check memory usage
free -h
top

# Check which process is using memory
ps aux --sort=-%mem | head -10

# Restart services
sudo supervisorctl restart moneyone-api
sudo systemctl restart nginx

# Add more swap if needed
sudo fallocate -l 4G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2
```



---

## PART 16: Updating Your Application

### How to Deploy Updates

**1. Update Backend Code:**
```bash
# SSH to server
ssh -i moneyone-production.pem ubuntu@XX.XX.XX.XX

# Navigate to project
cd /var/www/moneyone/moneyone

# Pull latest code (if using Git)
git pull origin main

# Or upload new files using SCP/rsync

# Activate virtual environment
cd backend
source venv/bin/activate

# Install any new dependencies
pip install -r requirements.txt

# Restart backend
sudo supervisorctl restart moneyone-api

# Check status
sudo supervisorctl status moneyone-api
```

**2. Update Frontend (Admin):**
```bash
cd /var/www/moneyone/moneyone/moneyone_admin

# Pull latest code
git pull origin main

# Install new dependencies
npm install

# Build
npm run build

# Deploy
sudo cp -r dist/* /var/www/admin.moneyone.co.in/

# Clear cache (optional)
sudo systemctl reload nginx
```

**3. Update Frontend (Merchant):**
```bash
cd /var/www/moneyone/moneyone/moneyone_client

# Pull latest code
git pull origin main

# Install new dependencies
npm install

# Build
npm run build

# Deploy
sudo cp -r dist/* /var/www/partner.moneyone.co.in/

# Clear cache (optional)
sudo systemctl reload nginx
```

**4. Database Migrations:**
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate

# Run migration script (if you have one)
python migrate.py

# Or manually update database
mysql -u moneyone_user -p moneyone_db < migration.sql
```

---

## PART 17: Performance Optimization

### Optimization Tips

**1. Enable Nginx Caching:**
```bash
sudo nano /etc/nginx/nginx.conf
```

Add inside http block:
```nginx
# Cache settings
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=100m inactive=60m use_temp_path=off;
```

**2. Optimize Gunicorn Workers:**
```bash
# Calculate optimal workers: (2 x CPU cores) + 1
# For t3.medium (2 cores): 5 workers

sudo nano /etc/supervisor/conf.d/moneyone-api.conf
```

Change workers:
```ini
command=/var/www/moneyone/moneyone/backend/venv/bin/gunicorn --workers 5 --worker-class gevent --bind 127.0.0.1:5000 ...
```

**3. Database Query Optimization:**
```sql
-- Add indexes for frequently queried columns
ALTER TABLE payin_transactions ADD INDEX idx_merchant_id (merchant_id);
ALTER TABLE payin_transactions ADD INDEX idx_status (status);
ALTER TABLE payin_transactions ADD INDEX idx_created_at (created_at);
```

**4. Enable Redis Caching (Optional):**
```bash
# Install Redis
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Install Python Redis client
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install redis flask-caching
```

---

## PART 18: Disaster Recovery

### Backup Strategy

**1. Automated Daily Backups:**
Already configured in Step 38

**2. Manual Backup Before Updates:**
```bash
# Create backup before any major update
~/backup.sh

# Verify backup
ls -lh ~/backups/
```

**3. Restore from Backup:**
```bash
# Restore database
gunzip < ~/backups/db_backup_YYYYMMDD_HHMMSS.sql.gz | mysql -u moneyone_user -p moneyone_db

# Restore uploads
tar -xzf ~/backups/uploads_backup_YYYYMMDD_HHMMSS.tar.gz -C /

# Restore environment
tar -xzf ~/backups/env_backup_YYYYMMDD_HHMMSS.tar.gz -C /

# Restart services
sudo supervisorctl restart moneyone-api
```

**4. AWS Snapshot Backup:**
```bash
# Create EC2 snapshot from AWS Console
# EC2 > Instances > Select Instance > Actions > Image and templates > Create image

# Or use AWS CLI
aws ec2 create-image --instance-id i-1234567890abcdef0 --name "MoneyOne-Backup-$(date +%Y%m%d)"
```

---

## PART 19: Scaling Considerations

### When to Scale

**Vertical Scaling (Upgrade Instance):**
- CPU usage consistently > 70%
- Memory usage consistently > 80%
- Response times increasing

**Upgrade path:**
- t3.medium → t3.large → t3.xlarge
- Or switch to c5/m5 instances for better performance

**Horizontal Scaling (Multiple Instances):**
- Use AWS Load Balancer
- Deploy multiple EC2 instances
- Use RDS for shared database
- Use S3 for shared file storage

---

## PART 20: Final Checklist

### Production Readiness Checklist

- [ ] EC2 instance running and accessible
- [ ] All three domains pointing to EC2 IP
- [ ] SSL certificates installed and auto-renewing
- [ ] Admin dashboard accessible via HTTPS
- [ ] Merchant dashboard accessible via HTTPS
- [ ] Backend API responding correctly
- [ ] Database configured and secured
- [ ] All services auto-start on reboot
- [ ] Firewall configured (UFW)
- [ ] Fail2Ban protecting SSH
- [ ] Automated backups configured
- [ ] Log rotation configured
- [ ] Monitoring script working
- [ ] All environment variables set correctly
- [ ] SMTP email working
- [ ] File uploads working
- [ ] PayU integration configured
- [ ] Admin user created
- [ ] Test transactions completed
- [ ] Error logs checked
- [ ] Performance tested
- [ ] Security audit completed
- [ ] Documentation updated

---

## Support & Resources

### Useful Commands Reference

```bash
# Service Management
sudo systemctl status nginx
sudo systemctl restart nginx
sudo supervisorctl status
sudo supervisorctl restart moneyone-api

# Logs
sudo tail -f /var/log/nginx/api.orchpay.in.error.log
sudo tail -f /var/log/moneyone/api-error.log
sudo journalctl -u nginx -f

# Database
mysql -u moneyone_user -p moneyone_db
sudo systemctl status mysql

# Disk Space
df -h
du -sh /var/www/*

# Process Monitoring
htop
ps aux | grep gunicorn

# Network
sudo netstat -tlnp
sudo ss -tlnp
```

### Important File Locations

```
Application: /var/www/moneyone/moneyone/
Admin Frontend: /var/www/admin.moneyone.co.in/
Merchant Frontend: /var/www/partner.moneyone.co.in/
Backend: /var/www/moneyone/moneyone/backend/
Uploads: /var/www/moneyone/moneyone/backend/uploads/

Nginx Configs: /etc/nginx/sites-available/
Supervisor Configs: /etc/supervisor/conf.d/
SSL Certificates: /etc/letsencrypt/live/

Logs:
- Application: /var/log/moneyone/
- Nginx: /var/log/nginx/
- MySQL: /var/log/mysql/
- System: /var/log/syslog

Backups: /home/ubuntu/backups/
```

---

## Congratulations! 🎉

Your MoneyOne application is now live on AWS EC2 with:
- ✅ Secure HTTPS access
- ✅ Three separate domains
- ✅ Automated backups
- ✅ Process management
- ✅ Security hardening
- ✅ Monitoring and logging

**Next Steps:**
1. Test all functionality thoroughly
2. Monitor logs for first few days
3. Set up CloudWatch for advanced monitoring (optional)
4. Configure email alerts for critical errors
5. Plan for scaling as traffic grows

**Need Help?**
- Check logs first: `/var/log/moneyone/` and `/var/log/nginx/`
- Review troubleshooting section
- Verify all services are running
- Check firewall and security group settings

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Author:** MoneyOne DevOps Team
