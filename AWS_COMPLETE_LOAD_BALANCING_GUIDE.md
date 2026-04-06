# Complete AWS Load Balancing Setup Guide (A to Z)

## Overview
This guide will walk you through setting up a complete load-balanced infrastructure for your MoneyOne application on AWS, from basic networking (VPC) to auto-scaling instances.

**What You'll Build:**
- Virtual Private Cloud (VPC) with proper networking
- RDS MySQL Database (managed, scalable)
- Application Load Balancer (distributes traffic)
- Auto Scaling Group (handles high load automatically)
- CloudWatch Monitoring (tracks performance)

**Time Required:** 2-3 hours
**Cost Estimate:** ~$50-100/month (depending on traffic)

---

## Prerequisites

Before starting, ensure you have:
- [ ] AWS Account with admin access
- [ ] Current EC2 instance running (13.234.15.221)
- [ ] Database backup ready (we'll create this first)
- [ ] Basic understanding of your application structure

---

## Phase 1: Backup Your Current Database

**Why:** Safety first - never migrate without a backup!

### Step 1.1: Create Database Dump

```bash
# Connect to your current EC2 instance
# Run this command to create a backup
mysqldump -u root -p moneyone_db > /var/www/html/moneyone_db_backup.sql

# Compress it to save space
gzip /var/www/html/moneyone_db_backup.sql

# Verify the backup was created
ls -lh /var/www/html/moneyone_db_backup.sql.gz
```

### Step 1.2: Download Backup (Browser Method)

Since you're using a browser terminal, use Python HTTP server:

```bash
# Navigate to the backup location
cd /var/www/html

# Start a simple HTTP server on port 8000
python3 -m http.server 8000
```

Then open in your browser:
```
http://13.234.15.221:8000/moneyone_db_backup.sql.gz
```

**Alternative:** Upload to Google Drive (see GOOGLE_DRIVE_BACKUP_QUICK_START.md)

---

## Phase 2: Understanding AWS Regions and Availability Zones

**What is a Region?**
- Geographic location (e.g., Mumbai, Singapore, US East)
- Your current instance is in: `ap-south-1` (Mumbai)

**What is an Availability Zone (AZ)?**
- Isolated data centers within a region
- Mumbai has 3 AZs: ap-south-1a, ap-south-1b, ap-south-1c
- Load balancers need at least 2 AZs for high availability

**Decision:** We'll use `ap-south-1` (Mumbai) region with 2 AZs

---

## Phase 3: Create VPC (Virtual Private Cloud)

**What is VPC?**
- Your own isolated network in AWS
- Like having your own private data center

### Step 3.1: Create VPC

1. Go to AWS Console → VPC Dashboard
2. Click "Create VPC"
3. Fill in details:
   - **Name:** `moneyone-vpc`
   - **IPv4 CIDR:** `10.0.0.0/16` (gives you 65,536 IP addresses)
   - **IPv6 CIDR:** No IPv6 CIDR block
   - **Tenancy:** Default
4. Click "Create VPC"

**What you just did:** Created your own private network space

---

## Phase 4: Create Subnets

**What are Subnets?**
- Subdivisions of your VPC
- Public subnets: Can access internet (for load balancer)
- Private subnets: Cannot access internet directly (for app servers, database)

### Step 4.1: Create Public Subnet 1

1. Go to VPC Dashboard → Subnets
2. Click "Create subnet"
3. Fill in:
   - **VPC:** Select `moneyone-vpc`
   - **Name:** `moneyone-public-subnet-1a`
   - **Availability Zone:** `ap-south-1a`
   - **IPv4 CIDR:** `10.0.1.0/24` (256 addresses)
4. Click "Create subnet"

### Step 4.2: Create Public Subnet 2

Repeat above with:
- **Name:** `moneyone-public-subnet-1b`
- **Availability Zone:** `ap-south-1b`
- **IPv4 CIDR:** `10.0.2.0/24`

### Step 4.3: Create Private Subnet 1

Repeat with:
- **Name:** `moneyone-private-subnet-1a`
- **Availability Zone:** `ap-south-1a`
- **IPv4 CIDR:** `10.0.10.0/24`

### Step 4.4: Create Private Subnet 2

Repeat with:
- **Name:** `moneyone-private-subnet-1b`
- **Availability Zone:** `ap-south-1b`
- **IPv4 CIDR:** `10.0.11.0/24`

**Summary:** You now have 4 subnets (2 public, 2 private) across 2 availability zones

---

## Phase 5: Create Internet Gateway

**What is Internet Gateway?**
- Allows your VPC to communicate with the internet
- Required for public subnets

### Step 5.1: Create and Attach IGW

1. Go to VPC Dashboard → Internet Gateways
2. Click "Create internet gateway"
3. **Name:** `moneyone-igw`
4. Click "Create"
5. Select the IGW → Actions → Attach to VPC
6. Select `moneyone-vpc` → Attach

---

## Phase 6: Create NAT Gateway

**What is NAT Gateway?**
- Allows private subnets to access internet (for updates, etc.)
- But internet cannot initiate connections to private subnets

### Step 6.1: Allocate Elastic IP

1. Go to VPC Dashboard → Elastic IPs
2. Click "Allocate Elastic IP address"
3. Click "Allocate"

### Step 6.2: Create NAT Gateway

1. Go to VPC Dashboard → NAT Gateways
2. Click "Create NAT gateway"
3. Fill in:
   - **Name:** `moneyone-nat-gw`
   - **Subnet:** Select `moneyone-public-subnet-1a`
   - **Elastic IP:** Select the IP you just allocated
4. Click "Create NAT gateway"

**Note:** NAT Gateway takes 2-3 minutes to become available

---

## Phase 7: Configure Route Tables

**What are Route Tables?**
- Define how traffic flows in your VPC
- Each subnet needs a route table

### Step 7.1: Create Public Route Table

1. Go to VPC Dashboard → Route Tables
2. Click "Create route table"
3. Fill in:
   - **Name:** `moneyone-public-rt`
   - **VPC:** `moneyone-vpc`
4. Click "Create"

### Step 7.2: Add Internet Route to Public RT

1. Select `moneyone-public-rt`
2. Go to "Routes" tab → Edit routes
3. Add route:
   - **Destination:** `0.0.0.0/0`
   - **Target:** Select Internet Gateway → `moneyone-igw`
4. Save changes

### Step 7.3: Associate Public Subnets

1. Still in `moneyone-public-rt`
2. Go to "Subnet associations" tab → Edit subnet associations
3. Select both public subnets:
   - `moneyone-public-subnet-1a`
   - `moneyone-public-subnet-1b`
4. Save associations

### Step 7.4: Create Private Route Table

1. Create new route table:
   - **Name:** `moneyone-private-rt`
   - **VPC:** `moneyone-vpc`

### Step 7.5: Add NAT Route to Private RT

1. Select `moneyone-private-rt`
2. Edit routes → Add route:
   - **Destination:** `0.0.0.0/0`
   - **Target:** NAT Gateway → `moneyone-nat-gw`
3. Save changes

### Step 7.6: Associate Private Subnets

1. Edit subnet associations
2. Select both private subnets:
   - `moneyone-private-subnet-1a`
   - `moneyone-private-subnet-1b`
3. Save associations

**What you just did:** 
- Public subnets can access internet via Internet Gateway
- Private subnets can access internet via NAT Gateway (one-way)

---

## Phase 8: Create Security Groups

**What are Security Groups?**
- Virtual firewalls for your instances
- Control inbound and outbound traffic

### Step 8.1: Create Load Balancer Security Group

1. Go to EC2 Dashboard → Security Groups
2. Click "Create security group"
3. Fill in:
   - **Name:** `moneyone-alb-sg`
   - **Description:** Security group for Application Load Balancer
   - **VPC:** `moneyone-vpc`

4. **Inbound Rules:**
   - Type: HTTP, Port: 80, Source: 0.0.0.0/0 (anywhere)
   - Type: HTTPS, Port: 443, Source: 0.0.0.0/0 (anywhere)

5. **Outbound Rules:** (default - all traffic allowed)

6. Click "Create security group"

### Step 8.2: Create Application Security Group

1. Create another security group:
   - **Name:** `moneyone-app-sg`
   - **Description:** Security group for application servers
   - **VPC:** `moneyone-vpc`

2. **Inbound Rules:**
   - Type: Custom TCP, Port: 5000, Source: `moneyone-alb-sg` (select the ALB security group)
   - Type: SSH, Port: 22, Source: Your IP (for management)

3. **Outbound Rules:** (default - all traffic allowed)

4. Click "Create security group"

### Step 8.3: Create RDS Security Group

1. Create security group:
   - **Name:** `moneyone-rds-sg`
   - **Description:** Security group for RDS database
   - **VPC:** `moneyone-vpc`

2. **Inbound Rules:**
   - Type: MySQL/Aurora, Port: 3306, Source: `moneyone-app-sg` (select app security group)

3. **Outbound Rules:** (default)

4. Click "Create security group"

**What you just did:** Created firewall rules that allow:
- Internet → Load Balancer (ports 80, 443)
- Load Balancer → App Servers (port 5000)
- App Servers → Database (port 3306)

---

## Phase 9: Create RDS Database

**What is RDS?**
- Managed MySQL database service
- AWS handles backups, updates, scaling
- Much better than running MySQL on EC2

### Step 9.1: Create DB Subnet Group

1. Go to RDS Dashboard → Subnet groups
2. Click "Create DB subnet group"
3. Fill in:
   - **Name:** `moneyone-db-subnet-group`
   - **Description:** Subnet group for MoneyOne database
   - **VPC:** `moneyone-vpc`
   - **Availability Zones:** Select `ap-south-1a` and `ap-south-1b`
   - **Subnets:** Select both private subnets (10.0.10.0/24 and 10.0.11.0/24)
4. Click "Create"

### Step 9.2: Create RDS Instance

1. Go to RDS Dashboard → Databases
2. Click "Create database"
3. **Choose creation method:** Standard create

4. **Engine options:**
   - Engine: MySQL
   - Version: MySQL 8.0.35 (or latest 8.0.x)

5. **Templates:** Production (or Dev/Test if cost is a concern)

6. **Settings:**
   - **DB instance identifier:** `moneyone-db`
   - **Master username:** `admin`
   - **Master password:** Create a strong password (save it securely!)
   - **Confirm password:** Re-enter password

7. **Instance configuration:**
   - **DB instance class:** 
     - For production: `db.t3.medium` (2 vCPU, 4 GB RAM)
     - For testing: `db.t3.micro` (2 vCPU, 1 GB RAM)

8. **Storage:**
   - **Storage type:** General Purpose SSD (gp3)
   - **Allocated storage:** 20 GB (start small, can increase later)
   - **Enable storage autoscaling:** Yes
   - **Maximum storage threshold:** 100 GB

9. **Connectivity:**
   - **VPC:** `moneyone-vpc`
   - **DB subnet group:** `moneyone-db-subnet-group`
   - **Public access:** No
   - **VPC security group:** Choose existing → `moneyone-rds-sg`
   - **Availability Zone:** No preference

10. **Database authentication:** Password authentication

11. **Additional configuration:**
    - **Initial database name:** `moneyone_db`
    - **Backup retention period:** 7 days
    - **Enable encryption:** Yes (default AWS key)
    - **Enable Enhanced monitoring:** Yes (60 seconds)

12. Click "Create database"

**Wait time:** 10-15 minutes for database to be created

### Step 9.3: Note Down RDS Endpoint

Once created:
1. Go to RDS Dashboard → Databases
2. Click on `moneyone-db`
3. Copy the **Endpoint** (looks like: `moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com`)
4. Save this - you'll need it for your application configuration

---

## Phase 10: Import Database to RDS

### Step 10.1: Connect to Your Current EC2

```bash
# You're already connected via browser terminal
# Verify your backup file exists
ls -lh /var/www/html/moneyone_db_backup.sql.gz
```

### Step 10.2: Decompress Backup

```bash
# Decompress the backup
gunzip /var/www/html/moneyone_db_backup.sql.gz

# Verify
ls -lh /var/www/html/moneyone_db_backup.sql
```

### Step 10.3: Import to RDS

```bash
# Replace RDS_ENDPOINT with your actual RDS endpoint
# Replace MASTER_PASSWORD with your RDS password

mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com \
      -u admin \
      -p \
      moneyone_db < /var/www/html/moneyone_db_backup.sql
```

When prompted, enter your RDS master password.

**Wait time:** 2-5 minutes depending on database size

### Step 10.4: Verify Import

```bash
# Connect to RDS
mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com \
      -u admin \
      -p \
      moneyone_db

# Once connected, run:
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM transactions;

# Exit
exit;
```

---

## Phase 11: Create AMI from Current Instance

**What is AMI?**
- Amazon Machine Image - snapshot of your EC2 instance
- Used to launch identical copies for auto-scaling

### Step 11.1: Update Application Configuration

Before creating AMI, update your app to use RDS:

```bash
# Edit your backend .env file
nano /var/www/moneyone/backend/.env
```

Update database configuration:
```
DB_HOST=moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com
DB_USER=admin
DB_PASSWORD=your_rds_password
DB_NAME=moneyone_db
DB_PORT=3306
```

Save and exit (Ctrl+X, Y, Enter)

### Step 11.2: Restart Application

```bash
# Restart your application
sudo systemctl restart moneyone  # or however you run your app
```

### Step 11.3: Test RDS Connection

```bash
# Test if app connects to RDS
curl http://localhost:5000/health  # or your health check endpoint
```

### Step 11.4: Create AMI

1. Go to EC2 Dashboard → Instances
2. Select your current instance (13.234.15.221)
3. Actions → Image and templates → Create image
4. Fill in:
   - **Image name:** `moneyone-app-v1`
   - **Image description:** MoneyOne application with RDS configuration
   - **No reboot:** Uncheck (allow reboot for consistency)
5. Click "Create image"

**Wait time:** 5-10 minutes

---

## Phase 12: Create Launch Template

**What is Launch Template?**
- Blueprint for launching new EC2 instances
- Defines instance type, AMI, security groups, etc.

### Step 12.1: Create Launch Template

1. Go to EC2 Dashboard → Launch Templates
2. Click "Create launch template"
3. Fill in:

   **Launch template name:** `moneyone-app-template`
   
   **Template version description:** Initial version with RDS config
   
   **Application and OS Images (AMI):**
   - Click "My AMIs"
   - Select `moneyone-app-v1`
   
   **Instance type:** `t3.medium` (2 vCPU, 4 GB RAM)
   
   **Key pair:** Select your existing key pair (for SSH access)
   
   **Network settings:**
   - Don't include in launch template (we'll set this in Auto Scaling Group)
   
   **Security groups:** Select `moneyone-app-sg`
   
   **Advanced details:**
   - **IAM instance profile:** None (unless you need AWS SDK access)
   - **User data:** (optional - for startup scripts)
   
   ```bash
   #!/bin/bash
   cd /var/www/moneyone/backend
   source venv/bin/activate
   gunicorn --bind 0.0.0.0:5000 app:app --daemon
   ```

4. Click "Create launch template"

---

## Phase 13: Create Target Group

**What is Target Group?**
- Group of instances that receive traffic from load balancer
- Load balancer checks health of targets before sending traffic

### Step 13.1: Create Target Group

1. Go to EC2 Dashboard → Target Groups
2. Click "Create target group"
3. Fill in:

   **Choose a target type:** Instances
   
   **Target group name:** `moneyone-app-tg`
   
   **Protocol:** HTTP
   
   **Port:** 5000 (your application port)
   
   **VPC:** `moneyone-vpc`
   
   **Protocol version:** HTTP1
   
   **Health check settings:**
   - **Health check protocol:** HTTP
   - **Health check path:** `/health` (create this endpoint if you don't have one)
   - **Advanced health check settings:**
     - Healthy threshold: 2
     - Unhealthy threshold: 3
     - Timeout: 5 seconds
     - Interval: 30 seconds
     - Success codes: 200

4. Click "Next"

5. **Register targets:** Skip for now (Auto Scaling will add instances)

6. Click "Create target group"

---

## Phase 14: Create Application Load Balancer

**What is Application Load Balancer?**
- Distributes incoming traffic across multiple instances
- Performs health checks
- Handles SSL termination

### Step 14.1: Create Load Balancer

1. Go to EC2 Dashboard → Load Balancers
2. Click "Create load balancer"
3. Select "Application Load Balancer"
4. Click "Create"

5. **Basic configuration:**
   - **Name:** `moneyone-alb`
   - **Scheme:** Internet-facing
   - **IP address type:** IPv4

6. **Network mapping:**
   - **VPC:** `moneyone-vpc`
   - **Mappings:** Select both availability zones:
     - `ap-south-1a` → `moneyone-public-subnet-1a`
     - `ap-south-1b` → `moneyone-public-subnet-1b`

7. **Security groups:**
   - Remove default
   - Select `moneyone-alb-sg`

8. **Listeners and routing:**
   - **Protocol:** HTTP
   - **Port:** 80
   - **Default action:** Forward to `moneyone-app-tg`

9. **Summary:** Review settings

10. Click "Create load balancer"

**Wait time:** 2-3 minutes

### Step 14.2: Note Down Load Balancer DNS

1. Go to Load Balancers
2. Select `moneyone-alb`
3. Copy the **DNS name** (looks like: `moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com`)
4. Save this - this is your new application URL

---

## Phase 15: Create Auto Scaling Group

**What is Auto Scaling Group?**
- Automatically adds/removes instances based on load
- Maintains desired number of healthy instances
- Scales up during high traffic, scales down during low traffic

### Step 15.1: Create Auto Scaling Group

1. Go to EC2 Dashboard → Auto Scaling Groups
2. Click "Create Auto Scaling group"

3. **Step 1: Choose launch template**
   - **Name:** `moneyone-asg`
   - **Launch template:** `moneyone-app-template`
   - Click "Next"

4. **Step 2: Choose instance launch options**
   - **VPC:** `moneyone-vpc`
   - **Availability Zones and subnets:** Select both private subnets:
     - `moneyone-private-subnet-1a`
     - `moneyone-private-subnet-1b`
   - Click "Next"

5. **Step 3: Configure advanced options**
   - **Load balancing:** Attach to an existing load balancer
   - **Choose from your load balancer target groups:** `moneyone-app-tg`
   - **Health checks:**
     - Health check type: ELB
     - Health check grace period: 300 seconds
   - **Monitoring:** Enable CloudWatch group metrics
   - Click "Next"

6. **Step 4: Configure group size and scaling policies**
   - **Group size:**
     - Desired capacity: 2
     - Minimum capacity: 2
     - Maximum capacity: 10
   
   - **Scaling policies:** Target tracking scaling policy
     - **Metric type:** Average CPU utilization
     - **Target value:** 70
     - **Instances need:** 300 seconds warm up
   
   - Click "Next"

7. **Step 5: Add notifications** (optional)
   - Skip for now
   - Click "Next"

8. **Step 6: Add tags**
   - Add tag:
     - Key: Name
     - Value: moneyone-app-instance
   - Click "Next"

9. **Step 7: Review**
   - Review all settings
   - Click "Create Auto Scaling group"

**What happens now:**
- Auto Scaling Group will launch 2 instances in private subnets
- Instances will register with target group
- Load balancer will start health checks
- Once healthy, traffic will flow through load balancer

**Wait time:** 5-10 minutes for instances to launch and become healthy

---

## Phase 16: Verify Setup

### Step 16.1: Check Instance Health

1. Go to EC2 Dashboard → Target Groups
2. Select `moneyone-app-tg`
3. Go to "Targets" tab
4. Wait until both instances show "healthy" status

### Step 16.2: Test Load Balancer

```bash
# Test from your local machine or browser
curl http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com

# Or open in browser:
http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com
```

You should see your application response!

### Step 16.3: Test Auto Scaling

```bash
# Install stress tool on one of the new instances (optional)
# This will trigger auto-scaling when CPU goes above 70%

# Connect to instance via Session Manager or SSH
sudo apt-get update
sudo apt-get install stress -y

# Generate CPU load
stress --cpu 4 --timeout 600

# Watch Auto Scaling Group - it should launch new instances
```

---

## Phase 17: Update DNS (Optional)

If you have a domain name:

1. Go to your DNS provider (Route 53, GoDaddy, etc.)
2. Create/Update A record or CNAME:
   - **Type:** CNAME
   - **Name:** api (or www, or @)
   - **Value:** `moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com`
   - **TTL:** 300

3. Wait for DNS propagation (5-30 minutes)

4. Test: `http://yourdomain.com`

---

## Phase 18: Setup SSL Certificate (Optional but Recommended)

### Step 18.1: Request Certificate in ACM

1. Go to AWS Certificate Manager (ACM)
2. Click "Request certificate"
3. Select "Request a public certificate"
4. **Domain names:** `yourdomain.com`, `www.yourdomain.com`
5. **Validation method:** DNS validation
6. Click "Request"

7. Follow DNS validation instructions (add CNAME records to your DNS)

### Step 18.2: Add HTTPS Listener to Load Balancer

1. Go to EC2 → Load Balancers
2. Select `moneyone-alb`
3. Go to "Listeners" tab
4. Click "Add listener"
5. Fill in:
   - **Protocol:** HTTPS
   - **Port:** 443
   - **Default action:** Forward to `moneyone-app-tg`
   - **Security policy:** ELBSecurityPolicy-2016-08
   - **Default SSL certificate:** Select your ACM certificate
6. Click "Add"

7. (Optional) Edit HTTP listener to redirect to HTTPS

---

## Phase 19: Setup CloudWatch Monitoring

### Step 19.1: Create CloudWatch Dashboard

1. Go to CloudWatch → Dashboards
2. Click "Create dashboard"
3. **Name:** `moneyone-monitoring`
4. Add widgets:
   - ALB Request Count
   - ALB Target Response Time
   - ALB Healthy Host Count
   - ASG CPU Utilization
   - RDS CPU Utilization
   - RDS Database Connections

### Step 19.2: Create Alarms

1. Go to CloudWatch → Alarms
2. Create alarms for:
   - High CPU on ASG (> 80%)
   - Unhealthy targets (< 1)
   - High RDS CPU (> 80%)
   - High RDS connections (> 80% of max)

---

## Phase 20: Cleanup Old Instance (After Verification)

**IMPORTANT:** Only do this after thoroughly testing the new setup!

### Step 20.1: Verify Everything Works

- [ ] Load balancer is accessible
- [ ] Application functions correctly
- [ ] Database queries work
- [ ] All features tested
- [ ] Monitored for 24-48 hours

### Step 20.2: Stop Old Instance

1. Go to EC2 Dashboard → Instances
2. Select your old instance (13.234.15.221)
3. Instance state → Stop instance
4. Wait 24 hours to ensure no issues

### Step 20.3: Terminate Old Instance

1. If everything is stable after 24 hours:
2. Select old instance
3. Instance state → Terminate instance

---

## Cost Optimization Tips

1. **Use Reserved Instances:** Save up to 72% for 1-year commitment
2. **Right-size instances:** Start small, scale as needed
3. **Use Spot Instances:** For non-critical workloads (up to 90% savings)
4. **Enable RDS storage autoscaling:** Pay only for what you use
5. **Delete unused resources:** Old snapshots, unattached volumes
6. **Use CloudWatch to identify idle resources**

---

## Troubleshooting

### Issue: Instances not becoming healthy

**Check:**
- Security group allows traffic from ALB to instances on port 5000
- Health check endpoint `/health` returns 200 status
- Application is running on port 5000
- Check instance logs: `/var/log/syslog` or application logs

### Issue: Cannot connect to RDS

**Check:**
- Security group allows traffic from app instances to RDS on port 3306
- RDS is in private subnets
- Connection string is correct
- RDS is in "Available" state

### Issue: Load balancer returns 503

**Check:**
- At least one target is healthy
- Target group health check is configured correctly
- Instances are registered with target group

### Issue: Auto Scaling not working

**Check:**
- CloudWatch metrics are being collected
- Scaling policy is configured correctly
- Cooldown period hasn't been reached
- Maximum capacity not reached

---

## Monitoring Commands

```bash
# Check Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names moneyone-asg

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier moneyone-db

# View CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=<alb-name> \
  --start-time 2026-03-04T00:00:00Z \
  --end-time 2026-03-04T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

---

## Summary

You've successfully set up:

✅ VPC with public and private subnets across 2 AZs
✅ Internet Gateway and NAT Gateway for connectivity
✅ Security Groups for network isolation
✅ RDS MySQL database (managed, scalable)
✅ Application Load Balancer (distributes traffic)
✅ Auto Scaling Group (handles 2-10 instances automatically)
✅ CloudWatch monitoring and alarms

**Your application can now:**
- Handle high traffic loads automatically
- Scale from 2 to 10 instances based on CPU
- Survive instance failures (auto-replacement)
- Survive availability zone failures
- Provide consistent performance

**Next Steps:**
1. Monitor for 1 week
2. Adjust scaling policies based on actual traffic
3. Setup SSL certificate for HTTPS
4. Configure automated backups
5. Setup CI/CD pipeline for deployments

---

## Quick Reference

**Load Balancer URL:** `http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com`

**RDS Endpoint:** `moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com`

**Auto Scaling:** 2-10 instances, scales at 70% CPU

**Estimated Monthly Cost:**
- ALB: $16-20
- EC2 (2x t3.medium): $60-70
- RDS (db.t3.medium): $50-60
- NAT Gateway: $32-45
- Data transfer: $10-20
- **Total: ~$170-215/month**

(Costs reduce with Reserved Instances and right-sizing)

---

**Need Help?** Refer to:
- AWS Documentation: https://docs.aws.amazon.com
- AWS Support: https://console.aws.amazon.com/support
- This guide: Read relevant phase again

**Good luck with your setup! 🚀**
