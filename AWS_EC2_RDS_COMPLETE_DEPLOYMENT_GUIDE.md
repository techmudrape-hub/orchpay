# Complete AWS EC2 + RDS Deployment Guide for OrchPay
## From Zero to Production - Step by Step

This guide will walk you through deploying your payment gateway application on AWS using:
- **EC2 Instance**: c7i.large (2 vCPU, 4 GB RAM)
- **RDS Database**: MySQL database
- **Application Load Balancer**: For distributing traffic
- **No Auto Scaling**: Single EC2 instance setup

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [VPC and Network Configuration](#vpc-and-network-configuration)
4. [RDS Database Setup](#rds-database-setup)
5. [EC2 Instance Setup](#ec2-instance-setup)
6. [Application Deployment](#application-deployment)
7. [Load Balancer Configuration](#load-balancer-configuration)
8. [Domain and SSL Setup](#domain-and-ssl-setup)
9. [Security Configuration](#security-configuration)
10. [Monitoring and Maintenance](#monitoring-and-maintenance)

---

## Prerequisites

Before starting, ensure you have:
- AWS account with billing enabled
- Domain name (for production use)
- Credit card for AWS billing
- Basic understanding of terminal/command line
- Your application code ready

---

## PHASE 1: AWS Account Setup

### Step 1.1: Create AWS Account

1. Go to [https://aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Enter your email address and choose account name
4. Provide contact information and credit card details
5. Verify your phone number
6. Choose "Basic Support - Free" plan
7. Complete the sign-up process

### Step 1.2: Access AWS Console
1. Go to [https://console.aws.amazon.com](https://console.aws.amazon.com)
2. Sign in with your root account credentials
3. Select your preferred region (e.g., `us-east-1`, `ap-south-1` for India)
   - **Important**: Use the same region for all resources

### Step 1.3: Create IAM User (Recommended for Security)
1. In AWS Console, search for "IAM"
2. Click "Users" → "Add users"
3. Username: `orchpay-admin`
4. Select "Provide user access to AWS Management Console"
5. Choose "I want to create an IAM user"
6. Set custom password
7. Click "Next"
8. Attach policies: `AdministratorAccess` (for full access)
9. Click "Create user"
10. Save the credentials securely
11. Use this IAM user for all future operations

---

## PHASE 2: VPC and Network Configuration

### Step 2.1: Create VPC (Virtual Private Cloud)

1. In AWS Console, search for "VPC"
2. Click "Create VPC"
3. Choose "VPC and more" (this creates everything automatically)
4. Configuration:
   - **Name tag**: `orchpay-vpc`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **Number of Availability Zones**: 2
   - **Number of public subnets**: 2
   - **Number of private subnets**: 2
   - **NAT gateways**: 1 per AZ (costs ~$32/month each)
   - **VPC endpoints**: None
5. Click "Create VPC"
6. Wait for creation to complete (~5 minutes)

### Step 2.2: Verify Network Components Created
After VPC creation, verify these were created:
- 1 VPC
- 2 Public subnets (for Load Balancer)
- 2 Private subnets (for EC2 and RDS)
- 1 Internet Gateway
- 2 NAT Gateways
- Route tables configured

---

## PHASE 3: RDS Database Setup

### Step 3.1: Create RDS Subnet Group
1. Search for "RDS" in AWS Console
2. Click "Subnet groups" in left sidebar
3. Click "Create DB subnet group"
4. Configuration:
   - **Name**: `orchpay-db-subnet-group`
   - **Description**: `Subnet group for OrchPay database`
   - **VPC**: Select `orchpay-vpc`
   - **Availability Zones**: Select 2 zones
   - **Subnets**: Select the 2 PRIVATE subnets
5. Click "Create"

### Step 3.2: Create RDS Security Group
1. Go to EC2 Console → Security Groups
2. Click "Create security group"
3. Configuration:
   - **Name**: `orchpay-rds-sg`
   - **Description**: `Security group for RDS database`
   - **VPC**: Select `orchpay-vpc`
4. Inbound rules:
   - **Type**: MySQL/Aurora
   - **Protocol**: TCP
   - **Port**: 3306
   - **Source**: Custom → Select EC2 security group (we'll create this next)
5. Click "Create security group"

### Step 3.3: Create RDS MySQL Database
1. Go to RDS Console
2. Click "Create database"
3. Configuration:

**Engine options:**
- Engine type: MySQL
- Version: MySQL 8.0.35 (or latest)

**Templates:**
- Choose: Production (or Dev/Test for lower cost)

**Settings:**
- **DB instance identifier**: `orchpay-db`
- **Master username**: `admin`
- **Master password**: Create strong password (save it securely!)
- **Confirm password**: Re-enter password

**Instance configuration:**
- **DB instance class**: Burstable classes → db.t3.medium (2 vCPU, 4 GB RAM)
  - For production: db.t3.large or db.m6g.large

**Storage:**
- **Storage type**: General Purpose SSD (gp3)
- **Allocated storage**: 100 GB
- **Enable storage autoscaling**: Yes
- **Maximum storage threshold**: 1000 GB

**Connectivity:**
- **VPC**: `orchpay-vpc`
- **DB subnet group**: `orchpay-db-subnet-group`
- **Public access**: No
- **VPC security group**: Choose existing → `orchpay-rds-sg`
- **Availability Zone**: No preference

**Database authentication:**
- Password authentication

**Additional configuration:**
- **Initial database name**: `moneyone_db`
- **DB parameter group**: default
- **Backup retention period**: 7 days
- **Enable encryption**: Yes (recommended)
- **Enable Enhanced monitoring**: Yes (optional, costs extra)

4. Click "Create database"
5. Wait 10-15 minutes for database to be created
6. Once status shows "Available", note down the **Endpoint** (looks like: `orchpay-db.xxxxxxxxx.region.rds.amazonaws.com`)

---

## PHASE 4: EC2 Instance Setup

### Step 4.1: Create EC2 Security Group
1. Go to EC2 Console → Security Groups
2. Click "Create security group"
3. Configuration:
   - **Name**: `orchpay-ec2-sg`
   - **Description**: `Security group for OrchPay EC2 instance`
   - **VPC**: Select `orchpay-vpc`

4. **Inbound rules** (Add these one by one):

   | Type | Protocol | Port | Source | Description |
   |------|----------|------|--------|-------------|
   | SSH | TCP | 22 | My IP | SSH access |
   | HTTP | TCP | 80 | 0.0.0.0/0 | HTTP traffic |
   | HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS traffic |
   | Custom TCP | TCP | 5000 | Load Balancer SG | Backend API |
   | Custom TCP | TCP | 5173 | Load Balancer SG | Admin Frontend |
   | Custom TCP | TCP | 5174 | Load Balancer SG | Client Frontend |

5. **Outbound rules**: Leave default (All traffic to 0.0.0.0/0)
6. Click "Create security group"

### Step 4.2: Update RDS Security Group
1. Go back to RDS security group (`orchpay-rds-sg`)
2. Edit inbound rules
3. Change source to `orchpay-ec2-sg` security group
4. Save rules

### Step 4.3: Create Key Pair for SSH Access
1. In EC2 Console, click "Key Pairs" in left sidebar
2. Click "Create key pair"
3. Configuration:
   - **Name**: `orchpay-key`
   - **Key pair type**: RSA
   - **Private key file format**: 
     - `.pem` for Mac/Linux
     - `.ppk` for Windows (PuTTY)
4. Click "Create key pair"
5. **Important**: Save the downloaded file securely - you cannot download it again!
6. For Mac/Linux, set permissions:
   ```bash
   chmod 400 orchpay-key.pem
   ```

### Step 4.4: Launch EC2 Instance
1. In EC2 Console, click "Instances" → "Launch instances"
2. Configuration:

**Name and tags:**
- **Name**: `orchpay-server`

**Application and OS Images (AMI):**
- **Quick Start**: Ubuntu
- **AMI**: Ubuntu Server 22.04 LTS (Free tier eligible)
- **Architecture**: 64-bit (x86)

**Instance type:**
- **Instance type**: c7i.large
  - 2 vCPU, 4 GB RAM
  - Search for "c7i.large" in the dropdown

**Key pair:**
- Select: `orchpay-key` (created earlier)

**Network settings:**
- Click "Edit"
- **VPC**: `orchpay-vpc`
- **Subnet**: Select one of the PRIVATE subnets
- **Auto-assign public IP**: Disable (we'll use Load Balancer)
- **Firewall (security groups)**: Select existing → `orchpay-ec2-sg`

**Configure storage:**
- **Size**: 50 GB
- **Volume type**: gp3
- **Delete on termination**: Yes

**Advanced details:**
- Leave defaults for now

3. Click "Launch instance"
4. Wait for instance state to show "Running"
5. Note down the **Private IP address**

### Step 4.5: Create Bastion Host (for SSH Access)
Since your EC2 is in a private subnet, you need a bastion host to access it:

1. Launch another EC2 instance:
   - **Name**: `orchpay-bastion`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: t2.micro (free tier)
   - **VPC**: `orchpay-vpc`
   - **Subnet**: Select a PUBLIC subnet
   - **Auto-assign public IP**: Enable
   - **Security group**: Create new
     - Name: `orchpay-bastion-sg`
     - Inbound: SSH (22) from My IP
   - **Key pair**: `orchpay-key`
   - **Storage**: 8 GB

2. Launch instance
3. Note down the **Public IP address**

### Step 4.6: Connect to EC2 Instance

**For Mac/Linux:**
```bash
# First, SSH into bastion host
ssh -i orchpay-key.pem ubuntu@<BASTION_PUBLIC_IP>

# From bastion, SSH into main server
ssh ubuntu@<EC2_PRIVATE_IP>
```

**For Windows (using PuTTY):**
1. Open PuTTY
2. Host Name: `ubuntu@<BASTION_PUBLIC_IP>`
3. Connection → SSH → Auth → Browse for your .ppk file
4. Click "Open"
5. Once connected to bastion, SSH to main server:
   ```bash
   ssh ubuntu@<EC2_PRIVATE_IP>
   ```

---

## PHASE 5: Application Deployment

### Step 5.1: Install Required Software on EC2

Once connected to your EC2 instance:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.11
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Install pip
sudo apt install -y python3-pip

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL client
sudo apt install -y mysql-client

# Install Nginx
sudo apt install -y nginx

# Install Git
sudo apt install -y git

# Install other dependencies
sudo apt install -y build-essential libssl-dev libffi-dev
sudo apt install -y libmysqlclient-dev pkg-config

# Verify installations
python3.11 --version
node --version
npm --version
nginx -v
mysql --version
```

### Step 5.2: Clone Your Application
```bash
# Create application directory
sudo mkdir -p /var/www/orchpay
sudo chown -R ubuntu:ubuntu /var/www/orchpay
cd /var/www/orchpay

# Clone your repository (replace with your repo URL)
git clone <YOUR_GITHUB_REPO_URL> orchpay
cd orchpay

# Or upload your code using SCP from your local machine:
# scp -i orchpay-key.pem -r /path/to/your/project ubuntu@<BASTION_IP>:/var/www/orchpay/
```

### Step 5.3: Setup Backend (Flask API)

```bash
cd /var/www/orchpay/orchpay/backend

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
nano .env
```

**Update .env file with your RDS credentials:**
```env
DB_HOST=<YOUR_RDS_ENDPOINT>
DB_USER=admin
DB_PASSWORD=<YOUR_RDS_PASSWORD>
DB_NAME=moneyone_db
JWT_SECRET_KEY=<GENERATE_STRONG_SECRET_KEY>
FLASK_ENV=production

# Keep all other payment gateway configurations as is
# Update CORS_ORIGINS with your domain
CORS_ORIGINS=https://orchpay.in,https://admin.orchpay.in,https://partner.orchpay.in

# Update UPLOADS_BASE_URL
UPLOADS_BASE_URL=https://api.orchpay.in/uploads
```

**Generate a strong JWT secret:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Step 5.4: Initialize Database

**Important:** Follow these steps in order to properly set up your database.

```bash
# Activate virtual environment
cd /var/www/orchpay/orchpay/backend
source venv/bin/activate

# Step 1: Test database connection
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p

# Enter your RDS password when prompted
# You should see: mysql>
# Type: SHOW DATABASES;
# You should see moneyone_db in the list
# Exit: exit
```

**Option A: Using Migration Script (Recommended)**

The migration script will:
- Create a backup of existing data
- Create all required tables
- Add missing columns
- Create indexes for performance
- Preserve existing data

```bash
# Run migration (creates backup + migrates)
python migrate_database.py

# Or dry-run to see what will be done
python migrate_database.py --dry-run

# Or backup only
python migrate_database.py --backup-only
```

**Option B: Using SQL File (Fresh Installation)**

If you have a complete SQL dump file:

```bash
# Import database schema
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p moneyone_db < moneyone_db.sql

# This will take a few minutes depending on file size
# Wait for the command to complete
```

**Step 2: Verify Database Tables**

```bash
# Check if all tables were created
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "USE moneyone_db; SHOW TABLES;"
```

You should see these tables:
- admin_users
- admin_activity_logs
- admin_banks
- admin_wallet
- admin_wallet_transactions
- commercial_schemes
- commercial_charges
- merchants
- merchant_documents
- merchant_ip_whitelist
- merchant_callbacks
- merchant_banks
- merchant_wallet
- merchant_unsettled_wallet
- payin_transactions
- payout_transactions
- wallet_transactions
- callback_logs
- fund_requests
- service_routing
- payu_webhook_config
- payu_webhook_logs
- payu_tokens

**Step 3: Create Admin User**

```bash
# Create admin user (admin@orchpay.in / Admin@123)
python create_orchpay_admin_user.py
```

The script will:
- Check if admin user exists
- Create new admin if doesn't exist
- Offer to reset password if already exists
- Display login credentials

**Step 4: Verify Admin User**

```bash
# Check admin user was created
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SELECT id, admin_id, is_active, created_at FROM moneyone_db.admin_users;"
```

You should see:
```
+----+--------------------+-----------+---------------------+
| id | admin_id           | is_active | created_at          |
+----+--------------------+-----------+---------------------+
|  1 | admin@orchpay.in   |         1 | 2026-04-06 10:30:00 |
+----+--------------------+-----------+---------------------+
```

**Step 5: Initialize Admin Wallet (Optional)**

```bash
# Create admin wallet entry
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p moneyone_db << EOF
INSERT INTO admin_wallet (admin_id, main_balance, unsettled_balance)
VALUES ('admin@orchpay.in', 0.00, 0.00)
ON DUPLICATE KEY UPDATE admin_id = admin_id;
EOF
```

**Default Admin Credentials:**
```
Email: admin@orchpay.in
Password: Admin@123
Login URL: https://admin.orchpay.in
```

**⚠️ IMPORTANT SECURITY NOTES:**
1. Change the admin password immediately after first login
2. The migration script creates automatic backups before making changes
3. Backup files are saved as: `backup_moneyone_db_YYYYMMDD_HHMMSS.sql`
4. Keep backup files secure and test restore procedures
5. Never commit credentials to version control

**Troubleshooting Database Issues:**

If migration fails:
```bash
# Check database connection
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SELECT 1;"

# Check database exists
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SHOW DATABASES LIKE 'moneyone_db';"

# Check user permissions
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "SHOW GRANTS;"

# View migration logs
python migrate_database.py --dry-run
```

If admin user creation fails:
```bash
# Check if admin_users table exists
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p -e "DESCRIBE moneyone_db.admin_users;"

# Manually create admin user
mysql -h <YOUR_RDS_ENDPOINT> -u admin -p moneyone_db << EOF
INSERT INTO admin_users (admin_id, password_hash, is_active, created_at)
VALUES ('admin@orchpay.in', 'scrypt:32768:8:1\$HASH_HERE', 1, NOW());
EOF

# Then run the script to set proper password
python create_orchpay_admin_user.py
```

### Step 5.5: Setup Backend as Systemd Service

```bash
# Create systemd service file
sudo nano /etc/systemd/system/orchpay-api.service
```

**Add this content:**
```ini
[Unit]
Description=OrchPay Backend API
After=network.target

[Service]
Type=notify
User=ubuntu
Group=ubuntu
WorkingDirectory=/var/www/orchpay/orchpay/backend
Environment="PATH=/var/www/orchpay/orchpay/backend/venv/bin"
ExecStart=/var/www/orchpay/orchpay/backend/venv/bin/gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 4 \
    --worker-class gevent \
    --worker-connections 1000 \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --access-logfile /var/www/orchpay/orchpay/backend/logs/access.log \
    --error-logfile /var/www/orchpay/orchpay/backend/logs/error.log \
    --log-level info \
    app:app

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Create logs directory and start service:**
```bash
# Create logs directory
mkdir -p /var/www/orchpay/orchpay/backend/logs

# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable orchpay-api

# Start the service
sudo systemctl start orchpay-api

# Check status
sudo systemctl status orchpay-api

# View logs
sudo journalctl -u orchpay-api -f
```

### Step 5.6: Build and Setup Frontend Applications

**Admin Frontend:**
```bash
cd /var/www/orchpay/orchpay/orchpay_admin

# Install dependencies
npm install

# Update .env file
nano .env
```

Add:
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

```bash
# Build for production
npm run build

# The build output will be in 'dist' folder
```

**Partner Frontend:**
```bash
cd /var/www/orchpay/orchpay/orchpay_client

# Install dependencies
npm install

# Update .env file
nano .env
```

Add:
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

```bash
# Build for production
npm run build

# The build output will be in 'dist' folder
```

### Step 5.7: Configure Nginx

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/orchpay
```

**Add this configuration:**
```nginx
# Backend API
server {
    listen 80;
    server_name api.orchpay.in;

    client_max_body_size 10M;

    # Backend API
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Uploads
    location /uploads {
        alias /var/www/orchpay/orchpay/backend/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}

# Admin Frontend
server {
    listen 80;
    server_name admin.orchpay.in;

    root /var/www/orchpay/orchpay/orchpay_admin/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Partner Frontend
server {
    listen 80;
    server_name partner.orchpay.in;

    root /var/www/orchpay/orchpay/orchpay_client/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**Enable the configuration:**
```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/orchpay /etc/nginx/sites-enabled/

# Remove default configuration
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx
```

---

## PHASE 6: Load Balancer Configuration

### Step 6.1: Create Target Groups

You need 3 target groups (one for each application):

**Target Group 1: Backend API**
1. Go to EC2 Console → Target Groups
2. Click "Create target group"
3. Configuration:
   - **Target type**: Instances
   - **Target group name**: `orchpay-api-tg`
   - **Protocol**: HTTP
   - **Port**: 80
   - **VPC**: `orchpay-vpc`
   - **Protocol version**: HTTP1
   - **Health check protocol**: HTTP
   - **Health check path**: `/api/health` (create this endpoint if not exists)
   - **Advanced health check settings**:
     - Healthy threshold: 2
     - Unhealthy threshold: 3
     - Timeout: 5 seconds
     - Interval: 30 seconds
     - Success codes: 200
4. Click "Next"
5. **Register targets**:
   - Select your EC2 instance (`orchpay-server`)
   - Port: 80
   - Click "Include as pending below"
6. Click "Create target group"

**Target Group 2: Admin Frontend**
1. Create another target group:
   - **Name**: `orchpay-admin-tg`
   - **Port**: 80
   - **Health check path**: `/`
   - Register same EC2 instance

**Target Group 3: Partner Frontend**
1. Create another target group:
   - **Name**: `orchpay-partner-tg`
   - **Port**: 80
   - **Health check path**: `/`
   - Register same EC2 instance

### Step 6.2: Create Load Balancer Security Group

1. Go to EC2 → Security Groups
2. Click "Create security group"
3. Configuration:
   - **Name**: `orchpay-alb-sg`
   - **Description**: `Security group for Application Load Balancer`
   - **VPC**: `orchpay-vpc`
4. **Inbound rules**:
   | Type | Protocol | Port | Source | Description |
   |------|----------|------|--------|-------------|
   | HTTP | TCP | 80 | 0.0.0.0/0 | HTTP from internet |
   | HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS from internet |
5. **Outbound rules**: All traffic to 0.0.0.0/0
6. Click "Create security group"

### Step 6.3: Update EC2 Security Group
1. Go to `orchpay-ec2-sg` security group
2. Edit inbound rules
3. Update the rules to allow traffic from ALB:
   - Port 80: Source = `orchpay-alb-sg`
   - Port 5000: Source = `orchpay-alb-sg`
4. Save rules

### Step 6.4: Create Application Load Balancer

1. Go to EC2 Console → Load Balancers
2. Click "Create Load Balancer"
3. Choose "Application Load Balancer"
4. Click "Create"

**Basic configuration:**
- **Name**: `orchpay-alb`
- **Scheme**: Internet-facing
- **IP address type**: IPv4

**Network mapping:**
- **VPC**: `orchpay-vpc`
- **Mappings**: Select BOTH public subnets (in different AZs)

**Security groups:**
- Remove default
- Select: `orchpay-alb-sg`

**Listeners and routing:**
- **Protocol**: HTTP
- **Port**: 80
- **Default action**: Forward to `orchpay-partner-tg`

5. Click "Create load balancer"
6. Wait for state to become "Active" (~5 minutes)
7. Note down the **DNS name** (looks like: `orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com`)

### Step 6.5: Configure Load Balancer Rules

1. Click on your load balancer (`orchpay-alb`)
2. Go to "Listeners" tab
3. Click on the HTTP:80 listener
4. Click "Manage rules"
5. Add rules for routing:

**Rule 1: API Traffic**
- Click "Add rule"
- **Name**: `api-routing`
- **IF**: Host header is `api.orchpay.in`
- **THEN**: Forward to `orchpay-api-tg`
- Priority: 1
- Save

**Rule 2: Admin Traffic**
- Click "Add rule"
- **Name**: `admin-routing`
- **IF**: Host header is `admin.orchpay.in`
- **THEN**: Forward to `orchpay-admin-tg`
- Priority: 2
- Save

**Rule 3: Partner Traffic**
- Click "Add rule"
- **Name**: `partner-routing`
- **IF**: Host header is `partner.orchpay.in`
- **THEN**: Forward to `orchpay-partner-tg`
- Priority: 3
- Save

6. Save all rules

---

## PHASE 7: Domain and SSL Setup

### Step 7.1: Configure DNS Records

In your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.):

1. Create A records or CNAME records:

**Using CNAME (Recommended):**
```
Type    Name      Value
CNAME   @         orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com
CNAME   www       orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com
CNAME   admin     orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com
CNAME   partner   orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com
CNAME   api       orchpay-alb-xxxxxxxxx.region.elb.amazonaws.com
```

2. Wait for DNS propagation (5-30 minutes)
3. Test with: `nslookup orchpay.in`

### Step 7.2: Request SSL Certificate (AWS Certificate Manager)

1. Go to AWS Certificate Manager (ACM)
2. **Important**: Make sure you're in the SAME region as your Load Balancer
3. Click "Request certificate"
4. Choose "Request a public certificate"
5. Click "Next"

**Domain names:**
Add all your domains:
```
orchpay.in
*.orchpay.in
```
(The wildcard `*.orchpay.in` covers admin.orchpay.in, partner.orchpay.in, api.orchpay.in, etc.)

**Validation method:**
- Choose "DNS validation"

**Key algorithm:**
- RSA 2048

6. Click "Request"
7. Click on the certificate ID
8. You'll see CNAME records for validation
9. Add these CNAME records to your domain DNS:
   - Copy the CNAME name and value
   - Add to your domain registrar's DNS settings
10. Wait for validation (5-30 minutes)
11. Status will change to "Issued"

### Step 7.3: Add HTTPS Listener to Load Balancer

1. Go to EC2 → Load Balancers
2. Select `orchpay-alb`
3. Go to "Listeners" tab
4. Click "Add listener"
5. Configuration:
   - **Protocol**: HTTPS
   - **Port**: 443
   - **Default action**: Forward to `orchpay-partner-tg`
   - **Security policy**: ELBSecurityPolicy-TLS13-1-2-2021-06
   - **Default SSL certificate**: Select your certificate from ACM
6. Click "Add"

7. Add the same rules as HTTP listener:
   - Rule for api.orchpay.in → orchpay-api-tg
   - Rule for admin.orchpay.in → orchpay-admin-tg
   - Rule for partner.orchpay.in → orchpay-partner-tg

### Step 7.4: Redirect HTTP to HTTPS

1. Go to your HTTP:80 listener
2. Edit the listener
3. Change default action:
   - **Action type**: Redirect
   - **Protocol**: HTTPS
   - **Port**: 443
   - **Status code**: 301 (Permanent redirect)
4. Save changes

Now all HTTP traffic will automatically redirect to HTTPS!

---

## PHASE 8: Security Configuration

### Step 8.1: Configure Security Groups (Final Review)

**ALB Security Group (`orchpay-alb-sg`):**
- Inbound: HTTP (80) and HTTPS (443) from 0.0.0.0/0
- Outbound: All traffic

**EC2 Security Group (`orchpay-ec2-sg`):**
- Inbound: 
  - Port 80 from ALB security group
  - Port 22 from Bastion security group
- Outbound: All traffic

**RDS Security Group (`orchpay-rds-sg`):**
- Inbound: Port 3306 from EC2 security group
- Outbound: All traffic

**Bastion Security Group (`orchpay-bastion-sg`):**
- Inbound: Port 22 from your IP only
- Outbound: All traffic

### Step 8.2: Enable CloudWatch Monitoring

1. Go to CloudWatch Console
2. Create alarms for:
   - EC2 CPU utilization > 80%
   - RDS CPU utilization > 80%
   - RDS storage space < 20%
   - ALB unhealthy target count > 0

**Example: CPU Alarm**
1. CloudWatch → Alarms → Create alarm
2. Select metric → EC2 → Per-Instance Metrics
3. Select your instance → CPUUtilization
4. Conditions: Greater than 80
5. Configure SNS notification (email alert)
6. Create alarm

### Step 8.3: Setup Automated Backups

**RDS Backups (Already configured):**
- Automatic daily backups enabled
- 7-day retention period
- Can restore to any point in time

**EC2 Backups (Create AMI):**
1. Go to EC2 → Instances
2. Select `orchpay-server`
3. Actions → Image and templates → Create image
4. Name: `orchpay-server-backup-YYYY-MM-DD`
5. Create image
6. Schedule this weekly using AWS Backup or Lambda

**Application Code Backups:**
```bash
# On EC2, create backup script
sudo nano /var/www/orchpay/backup.sh
```

Add:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/www/orchpay/backups"
mkdir -p $BACKUP_DIR

# Backup application
tar -czf $BACKUP_DIR/orchpay_$DATE.tar.gz /var/www/orchpay/orchpay

# Keep only last 7 backups
ls -t $BACKUP_DIR/orchpay_*.tar.gz | tail -n +8 | xargs rm -f

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/orchpay_$DATE.tar.gz s3://your-backup-bucket/
```

```bash
# Make executable
sudo chmod +x /var/www/orchpay/backup.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
```

Add line:
```
0 2 * * * /var/www/orchpay/backup.sh
```

### Step 8.4: Setup Firewall (UFW)

```bash
# On EC2 instance
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from <BASTION_PRIVATE_IP> to any port 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo ufw status
```

---

## PHASE 9: Monitoring and Maintenance

### Step 9.1: Application Monitoring

**Check Backend Status:**
```bash
# SSH to EC2
sudo systemctl status orchpay-api
sudo journalctl -u orchpay-api -f

# Check logs
tail -f /var/www/orchpay/orchpay/backend/logs/error.log
tail -f /var/www/orchpay/orchpay/backend/logs/access.log
```

**Check Nginx Status:**
```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

**Check Database Connection:**
```bash
mysql -h <RDS_ENDPOINT> -u admin -p -e "SHOW DATABASES;"
```

### Step 9.2: Performance Monitoring

**Install monitoring tools:**
```bash
# Install htop for system monitoring
sudo apt install -y htop

# Monitor system resources
htop

# Check disk usage
df -h

# Check memory usage
free -h

# Check network connections
sudo netstat -tulpn
```

### Step 9.3: Log Rotation

```bash
# Create logrotate config
sudo nano /etc/logrotate.d/orchpay
```

Add:
```
/var/www/orchpay/orchpay/backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 ubuntu ubuntu
    sharedscripts
    postrotate
        systemctl reload orchpay-api > /dev/null 2>&1 || true
    endscript
}
```

### Step 9.4: Deployment Updates

**To update your application:**

```bash
# SSH to EC2
cd /var/www/orchpay/orchpay

# Pull latest code
git pull origin main

# Update backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart orchpay-api

# Update admin frontend
cd ../orchpay_admin
npm install
npm run build

# Update client frontend
cd ../orchpay_client
npm install
npm run build

# Restart Nginx
sudo systemctl restart nginx
```

### Step 9.5: Database Maintenance

**Regular maintenance tasks:**

```bash
# Connect to RDS
mysql -h <RDS_ENDPOINT> -u admin -p

# Check database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema;

# Optimize tables (run monthly)
OPTIMIZE TABLE payin_transactions;
OPTIMIZE TABLE payout_transactions;
OPTIMIZE TABLE merchants;
OPTIMIZE TABLE admin_wallet;

# Check slow queries
SHOW FULL PROCESSLIST;
```

---

## PHASE 10: Testing and Verification

### Step 10.1: Test All Endpoints

**Test Partner Frontend:**
```bash
curl https://partner.orchpay.in
# Should return HTML
```

**Test Admin Frontend:**
```bash
curl https://admin.orchpay.in
# Should return HTML
```

**Test Backend API:**
```bash
curl https://api.orchpay.in/api/health
# Should return {"status": "healthy"}
```

### Step 10.2: Load Testing

```bash
# Install Apache Bench
sudo apt install -y apache2-utils

# Test API endpoint
ab -n 1000 -c 10 https://api.orchpay.in/api/health

# Test with authentication
ab -n 100 -c 5 -H "Authorization: Bearer YOUR_TOKEN" https://api.orchpay.in/api/merchants
```

### Step 10.3: Security Testing

**Check SSL Configuration:**
- Visit: https://www.ssllabs.com/ssltest/
- Enter your domain
- Should get A or A+ rating

**Check Headers:**
```bash
curl -I https://partner.orchpay.in
# Verify security headers are present
```

---

## Cost Estimation

### Monthly AWS Costs (Approximate)

| Service | Configuration | Monthly Cost (USD) |
|---------|--------------|-------------------|
| EC2 c7i.large | 2 vCPU, 4 GB RAM | ~$62 |
| RDS db.t3.medium | 2 vCPU, 4 GB RAM | ~$60 |
| RDS Storage | 100 GB gp3 | ~$12 |
| Application Load Balancer | Standard | ~$22 |
| NAT Gateway | 2 AZs | ~$64 |
| Data Transfer | ~100 GB/month | ~$9 |
| Elastic IP | For Bastion | ~$3.6 |
| **Total** | | **~$232/month** |

**Cost Optimization Tips:**
1. Use 1 NAT Gateway instead of 2 (saves $32/month)
2. Use Reserved Instances for EC2/RDS (save 30-40%)
3. Use t3.medium instead of c7i.large for lower traffic (saves $30/month)
4. Enable RDS storage autoscaling only when needed
5. Delete unused snapshots and AMIs regularly

---

## Troubleshooting Guide

### Common Issues and Solutions

**1. Cannot connect to EC2 instance**
- Check security group allows SSH from your IP
- Verify you're using correct key pair
- Ensure bastion host is running
- Check EC2 instance is in running state

**2. Load Balancer shows unhealthy targets**
```bash
# Check if application is running
sudo systemctl status orchpay-api
sudo systemctl status nginx

# Check if ports are listening
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :5000

# Check Nginx configuration
sudo nginx -t

# View application logs
sudo journalctl -u orchpay-api -n 100
```

**3. Cannot connect to RDS**
```bash
# Test from EC2
mysql -h <RDS_ENDPOINT> -u admin -p

# If fails, check:
# - RDS security group allows EC2 security group
# - RDS is in same VPC
# - RDS endpoint is correct in .env file
```

**4. 502 Bad Gateway Error**
- Backend service is down
- Check: `sudo systemctl status orchpay-api`
- Restart: `sudo systemctl restart orchpay-api`

**5. SSL Certificate Issues**
- Ensure certificate is in "Issued" status in ACM
- Verify DNS records are correct
- Check certificate is attached to HTTPS listener
- Wait for DNS propagation (up to 48 hours)

**6. High CPU Usage**
```bash
# Check processes
htop

# Check database queries
mysql -h <RDS_ENDPOINT> -u admin -p -e "SHOW FULL PROCESSLIST;"

# Increase workers if needed
sudo nano /etc/systemd/system/orchpay-api.service
# Change --workers 4 to --workers 8
sudo systemctl daemon-reload
sudo systemctl restart orchpay-api
```

**7. Out of Memory**
```bash
# Check memory
free -h

# Add swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**8. Disk Space Full**
```bash
# Check disk usage
df -h

# Find large files
sudo du -h /var/www/orchpay/orchpay | sort -rh | head -20

# Clean up logs
sudo journalctl --vacuum-time=7d
sudo find /var/www/orchpay/orchpay/backend/logs -name "*.log" -mtime +7 -delete
```

---

## Security Best Practices

1. **Never expose RDS publicly** - Always keep in private subnet
2. **Use IAM roles** instead of access keys when possible
3. **Enable MFA** on AWS root account
4. **Regular security updates**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
5. **Monitor CloudWatch logs** for suspicious activity
6. **Use AWS Secrets Manager** for sensitive credentials
7. **Enable AWS CloudTrail** for audit logging
8. **Regular backups** - Test restore procedures
9. **Implement rate limiting** in your application
10. **Use AWS WAF** on ALB for additional protection (optional, costs extra)

---

## Scaling Considerations

When you need to scale in the future:

**Vertical Scaling (Easier):**
1. Stop EC2 instance
2. Change instance type to larger size (e.g., c7i.xlarge)
3. Start instance
4. Same for RDS (requires downtime)

**Horizontal Scaling (More complex):**
1. Create Auto Scaling Group
2. Add multiple EC2 instances
3. Configure session management (Redis/ElastiCache)
4. Update target groups to use Auto Scaling Group
5. Set scaling policies based on CPU/memory

---

## Quick Reference Commands

### SSH Connection
```bash
# Connect to bastion
ssh -i orchpay-key.pem ubuntu@<BASTION_PUBLIC_IP>

# From bastion to main server
ssh ubuntu@<EC2_PRIVATE_IP>
```

### Service Management
```bash
# Backend API
sudo systemctl status orchpay-api
sudo systemctl restart orchpay-api
sudo systemctl stop orchpay-api
sudo systemctl start orchpay-api
sudo journalctl -u orchpay-api -f

# Nginx
sudo systemctl status nginx
sudo systemctl restart nginx
sudo nginx -t
```

### Log Viewing
```bash
# Backend logs
tail -f /var/www/orchpay/orchpay/backend/logs/error.log
tail -f /var/www/orchpay/orchpay/backend/logs/access.log

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# System logs
sudo journalctl -f
```

### Database Access
```bash
# Connect to RDS
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db

# Backup database
mysqldump -h <RDS_ENDPOINT> -u admin -p moneyone_db > backup.sql

# Restore database
mysql -h <RDS_ENDPOINT> -u admin -p moneyone_db < backup.sql
```

### Application Updates
```bash
cd /var/www/orchpay/orchpay
git pull origin main
cd backend && source venv/bin/activate && pip install -r requirements.txt
sudo systemctl restart orchpay-api
cd ../orchpay_admin && npm install && npm run build
cd ../orchpay_client && npm install && npm run build
sudo systemctl restart nginx
```

---

## Support and Resources

**AWS Documentation:**
- EC2: https://docs.aws.amazon.com/ec2/
- RDS: https://docs.aws.amazon.com/rds/
- ALB: https://docs.aws.amazon.com/elasticloadbalancing/
- VPC: https://docs.aws.amazon.com/vpc/

**AWS Support:**
- Basic (Free): Documentation and forums
- Developer ($29/month): Email support
- Business ($100/month): 24/7 phone support

**Monitoring Tools:**
- AWS CloudWatch: Built-in monitoring
- AWS X-Ray: Application tracing
- Third-party: Datadog, New Relic, Grafana

---

## Checklist

Use this checklist to track your deployment progress:

### Pre-Deployment
- [ ] AWS account created and verified
- [ ] IAM user created with admin access
- [ ] Domain name purchased
- [ ] Application code ready
- [ ] Database schema prepared

### Infrastructure Setup
- [ ] VPC created with public/private subnets
- [ ] NAT Gateways configured
- [ ] RDS subnet group created
- [ ] RDS security group configured
- [ ] RDS MySQL database created and accessible
- [ ] EC2 security group configured
- [ ] Key pair created and downloaded
- [ ] Bastion host launched
- [ ] Main EC2 instance launched

### Application Deployment
- [ ] Software installed on EC2 (Python, Node, Nginx, MySQL client)
- [ ] Application code deployed
- [ ] Backend .env configured with RDS credentials
- [ ] Database schema imported
- [ ] Admin user created
- [ ] Backend service configured and running
- [ ] Frontend applications built
- [ ] Nginx configured for all applications

### Load Balancer
- [ ] Target groups created (API, Admin, Client)
- [ ] ALB security group created
- [ ] Application Load Balancer created
- [ ] Listeners configured (HTTP and HTTPS)
- [ ] Routing rules configured
- [ ] Health checks passing

### Domain and SSL
- [ ] DNS records configured
- [ ] SSL certificate requested in ACM
- [ ] SSL certificate validated
- [ ] HTTPS listener configured
- [ ] HTTP to HTTPS redirect enabled

### Security
- [ ] Security groups properly configured
- [ ] Firewall (UFW) enabled on EC2
- [ ] CloudWatch alarms configured
- [ ] Backup strategy implemented
- [ ] MFA enabled on AWS account

### Testing
- [ ] All domains accessible (orchpay.in, admin, partner, api)
- [ ] HTTPS working correctly
- [ ] Backend API responding
- [ ] Admin panel accessible
- [ ] Partner portal accessible
- [ ] Database connections working
- [ ] Payment gateway integrations tested
- [ ] SSL rating checked (A or A+)

### Monitoring
- [ ] CloudWatch monitoring enabled
- [ ] Log rotation configured
- [ ] Backup scripts created
- [ ] Monitoring alerts configured

---

## Conclusion

Congratulations! You've successfully deployed your OrchPay payment gateway application on AWS with:

✅ Secure VPC with public and private subnets
✅ RDS MySQL database in private subnet
✅ EC2 c7i.large instance running your application
✅ Application Load Balancer distributing traffic
✅ SSL/HTTPS enabled for secure connections
✅ Proper security groups and firewall rules
✅ Monitoring and backup strategies

Your application is now production-ready and accessible at:
- Partner Portal: https://partner.orchpay.in
- Admin Panel: https://admin.orchpay.in
- Backend API: https://api.orchpay.in

**Admin Login Credentials:**
```
URL: https://admin.orchpay.in
Email: admin@orchpay.in
Password: Admin@123
```
⚠️ Change the password immediately after first login!

**Next Steps:**
1. Monitor application performance for first few days
2. Set up automated backups
3. Configure payment gateway webhooks with your new domain
4. Test all payment flows thoroughly
5. Consider implementing AWS WAF for additional security
6. Plan for scaling as traffic grows

**Need Help?**
- AWS Support: https://console.aws.amazon.com/support/
- AWS Forums: https://forums.aws.amazon.com/
- Stack Overflow: Tag questions with `amazon-web-services`

Good luck with your deployment! 🚀
