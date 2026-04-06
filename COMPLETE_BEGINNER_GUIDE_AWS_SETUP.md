# Complete Beginner's Guide: AWS Load Balancing Setup

## Overview

This guide will help you:
1. Migrate MySQL from EC2 to RDS
2. Set up Application Load Balancer
3. Configure Auto Scaling
4. Handle high traffic loads

**Estimated Time:** 3-4 hours  
**Cost:** ~$150-200/month for production setup

---

## PHASE 1: Prepare Your Current System

### Step 1.1: Check Current Database

SSH into your EC2 instance:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

Check MySQL status:
```bash
sudo systemctl status mysql
mysql -u root -p
```

In MySQL, check your database:
```sql
SHOW DATABASES;
USE your_database_name;
SHOW TABLES;
SELECT COUNT(*) FROM users;  -- Check data exists
EXIT;
```

### Step 1.2: Backup Your Database

Create a backup (VERY IMPORTANT):

**Option A: Upload to Google Drive (Recommended - No SSH needed)**

See detailed guide: **GOOGLE_DRIVE_BACKUP_GUIDE.md**

Quick steps:
```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure Google Drive (follow prompts)
rclone config

# Create and upload backup
mkdir -p ~/database_backups
mysqldump -u root -p your_database_name > ~/database_backups/backup_$(date +%Y%m%d).sql
gzip ~/database_backups/backup_*.sql
rclone copy ~/database_backups/backup_*.sql.gz gdrive:MoneyoneBackups/
```

Then verify at https://drive.google.com - you should see your backup in "MoneyoneBackups" folder.

**Option B: Download via SCP (If SSH works)**

```bash
# Create backup directory
mkdir -p ~/database_backups
cd ~/database_backups

# Backup database
mysqldump -u root -p your_database_name > moneyone_backup_$(date +%Y%m%d).sql

# Compress backup
gzip moneyone_backup_*.sql

# Download backup to your local computer (run from your local machine)
scp -i your-key.pem ubuntu@your-ec2-ip:~/database_backups/moneyone_backup_*.sql.gz ./
```

**Option C: Download via Browser**

```bash
# Create backup
mkdir -p ~/database_backups
mysqldump -u root -p your_database_name > ~/database_backups/backup_$(date +%Y%m%d).sql
gzip ~/database_backups/backup_*.sql

# Make accessible via web
sudo mkdir -p /var/www/html/temp_backups
sudo cp ~/database_backups/backup_*.sql.gz /var/www/html/temp_backups/
sudo chmod 644 /var/www/html/temp_backups/*.sql.gz

# Download in browser: http://your-ec2-ip/temp_backups/backup_YYYYMMDD.sql.gz
# Then upload to Google Drive manually

# Clean up after download
sudo rm -rf /var/www/html/temp_backups
```

### Step 1.3: Note Down Database Details

Create a file with your current database info:
```bash
cat > ~/db_info.txt << EOF
Database Name: your_database_name
Database User: your_db_user
Database Password: your_db_password
Database Port: 3306
Tables Count: (run: mysql -u root -p -e "USE your_database_name; SHOW TABLES;")
EOF
```

---

## PHASE 2: Create RDS MySQL Database

### Step 2.1: Login to AWS Console

1. Go to https://console.aws.amazon.com/
2. Login with your credentials
3. Select your region (top-right corner) - Choose closest to your users (e.g., ap-south-1 for India)

### Step 2.2: Create RDS Database

1. **Go to RDS Service:**
   - Search "RDS" in the top search bar
   - Click "RDS" to open the service

2. **Create Database:**
   - Click "Create database" button
   - Choose "Standard create"

3. **Engine Options:**
   - Select "MySQL"
   - Version: Choose "MySQL 8.0.35" (or latest 8.0.x)

4. **Templates:**
   - For Production: Select "Production"
   - For Testing: Select "Dev/Test" (cheaper)

5. **Settings:**
   ```
   DB instance identifier: moneyone-db
   Master username: admin
   Master password: [Create a strong password - SAVE THIS!]
   Confirm password: [Same password]
   ```

6. **Instance Configuration:**
   - For Production: `db.t3.medium` (2 vCPU, 4 GB RAM) - ~$60/month
   - For Testing: `db.t3.micro` (2 vCPU, 1 GB RAM) - ~$15/month

7. **Storage:**
   ```
   Storage type: General Purpose SSD (gp3)
   Allocated storage: 100 GB
   Enable storage autoscaling: Yes
   Maximum storage threshold: 200 GB
   ```

8. **Connectivity:**
   ```
   Virtual private cloud (VPC): Select your VPC (same as EC2)
   Subnet group: Create new or use default
   Public access: Yes (for now, we'll secure it later)
   VPC security group: Create new
   Security group name: moneyone-rds-sg
   Availability Zone: No preference
   ```

9. **Database Authentication:**
   - Select "Password authentication"

10. **Additional Configuration:**
    ```
    Initial database name: moneyone_db
    DB parameter group: default.mysql8.0
    Backup retention period: 7 days
    Enable encryption: Yes (recommended)
    Enable Enhanced monitoring: Yes
    Enable auto minor version upgrade: Yes
    ```

11. **Click "Create database"**
    - Wait 10-15 minutes for creation

### Step 2.3: Note RDS Endpoint

After creation:
1. Click on your database "moneyone-db"
2. Find "Endpoint & port" section
3. Copy the endpoint (looks like: `moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com`)
4. Save this endpoint - you'll need it!

```bash
# Save RDS details
cat > ~/rds_info.txt << EOF
RDS Endpoint: moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com
RDS Port: 3306
Master Username: admin
Master Password: [your-password]
Database Name: moneyone_db
EOF
```

---

## PHASE 3: Configure Security Groups

### Step 3.1: Update RDS Security Group

1. Go to EC2 Console → Security Groups
2. Find "moneyone-rds-sg"
3. Click "Edit inbound rules"
4. Add rule:
   ```
   Type: MySQL/Aurora
   Protocol: TCP
   Port: 3306
   Source: [Your EC2 security group ID] (e.g., sg-xxxxx)
   Description: Allow from EC2
   ```
5. Add another rule (temporary, for migration):
   ```
   Type: MySQL/Aurora
   Protocol: TCP
   Port: 3306
   Source: My IP
   Description: Temporary for migration
   ```
6. Click "Save rules"

### Step 3.2: Test Connection from EC2

SSH to your EC2:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install MySQL client if not installed
sudo apt update
sudo apt install mysql-client -y

# Test connection to RDS
mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com -u admin -p

# If connected successfully, you'll see:
# mysql>

# Check database
SHOW DATABASES;
USE moneyone_db;
EXIT;
```

---

## PHASE 4: Migrate Database to RDS

### Step 4.1: Import Data to RDS

**If backup is in Google Drive:**
```bash
# Download from Google Drive to EC2
rclone copy gdrive:MoneyoneBackups/moneyone_backup_*.sql.gz ~/database_backups/

# Or download to your computer and upload to EC2:
# scp -i your-key.pem backup.sql.gz ubuntu@your-ec2-ip:~/database_backups/
```

**Import to RDS:**
```bash
# Navigate to backup directory
cd ~/database_backups

# Uncompress backup if compressed
gunzip moneyone_backup_*.sql.gz

# Import to RDS (this may take 10-30 minutes depending on data size)
mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com \
      -u admin \
      -p \
      moneyone_db < moneyone_backup_*.sql

# Enter RDS password when prompted
```

### Step 4.2: Verify Data Migration

```bash
# Connect to RDS
mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com -u admin -p

# In MySQL:
USE moneyone_db;
SHOW TABLES;
SELECT COUNT(*) FROM users;  -- Compare with old database
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM wallet;
EXIT;
```

### Step 4.3: Update Backend Configuration

Edit your backend .env file:
```bash
cd ~/moneyone/backend  # Or wherever your backend is
nano .env
```

Update database connection:
```env
# OLD (comment out)
# DB_HOST=localhost
# DB_NAME=your_old_db_name
# DB_USER=your_old_user
# DB_PASSWORD=your_old_password

# NEW RDS Connection
DB_HOST=moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com
DB_NAME=moneyone_db
DB_USER=admin
DB_PASSWORD=your_rds_password
DB_PORT=3306
```

Save and exit (Ctrl+X, Y, Enter)

### Step 4.4: Test Backend with RDS

```bash
# Restart your backend
sudo systemctl restart moneyone-backend
# OR if running manually:
# pkill -f app.py
# python3 app.py

# Check logs
tail -f /var/log/moneyone/backend.log
# OR
journalctl -u moneyone-backend -f

# Test API
curl http://localhost:5000/health
```

### Step 4.5: Verify Application Works

1. Open your application in browser
2. Try logging in
3. Check if data loads correctly
4. Create a test transaction
5. Verify it appears in RDS:

```bash
mysql -h moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com -u admin -p
USE moneyone_db;
SELECT * FROM transactions ORDER BY created_at DESC LIMIT 5;
EXIT;
```

---

## PHASE 5: Create Application Load Balancer

### Step 5.1: Create Target Group

1. Go to EC2 Console → Target Groups (left sidebar)
2. Click "Create target group"
3. Configure:
   ```
   Target type: Instances
   Target group name: moneyone-backend-tg
   Protocol: HTTP
   Port: 5000
   VPC: [Select your VPC]
   Protocol version: HTTP1
   ```

4. Health checks:
   ```
   Health check protocol: HTTP
   Health check path: /health
   Advanced health check settings:
     - Healthy threshold: 2
     - Unhealthy threshold: 3
     - Timeout: 5 seconds
     - Interval: 30 seconds
     - Success codes: 200
   ```

5. Click "Next"

6. Register targets:
   - Select your current EC2 instance
   - Port: 5000
   - Click "Include as pending below"
   - Click "Create target group"

### Step 5.2: Create Application Load Balancer

1. Go to EC2 Console → Load Balancers
2. Click "Create Load Balancer"
3. Select "Application Load Balancer"
4. Configure:
   ```
   Load balancer name: moneyone-alb
   Scheme: Internet-facing
   IP address type: IPv4
   ```

5. Network mapping:
   ```
   VPC: [Your VPC]
   Mappings: Select at least 2 availability zones
     - Check: ap-south-1a
     - Check: ap-south-1b
   ```

6. Security groups:
   - Click "Create new security group"
   - Name: `moneyone-alb-sg`
   - Description: "Security group for Moneyone ALB"
   - Inbound rules:
     ```
     Type: HTTP, Port: 80, Source: 0.0.0.0/0
     Type: HTTPS, Port: 443, Source: 0.0.0.0/0
     ```
   - Create and select this security group

7. Listeners and routing:
   ```
   Protocol: HTTP
   Port: 80
   Default action: Forward to moneyone-backend-tg
   ```

8. Click "Create load balancer"

9. Wait 5-10 minutes for provisioning

### Step 5.3: Get ALB DNS Name

1. Click on your load balancer "moneyone-alb"
2. Copy the "DNS name" (looks like: `moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com`)
3. Test in browser: `http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com/health`

---

## PHASE 6: Update EC2 Security Group

Your EC2 should only accept traffic from ALB:

1. Go to EC2 Console → Security Groups
2. Find your EC2 security group
3. Edit inbound rules
4. Modify the rule for port 5000:
   ```
   Type: Custom TCP
   Port: 5000
   Source: [Select moneyone-alb-sg security group]
   Description: Allow from ALB only
   ```
5. Keep SSH rule (port 22) for your IP
6. Save rules

---

## PHASE 7: Create AMI (Amazon Machine Image)

Before auto-scaling, create an image of your working EC2:

1. Go to EC2 Console → Instances
2. Select your instance
3. Actions → Image and templates → Create image
4. Configure:
   ```
   Image name: moneyone-backend-v1
   Image description: Moneyone backend with RDS connection
   No reboot: Uncheck (recommended)
   ```
5. Click "Create image"
6. Wait 10-15 minutes
7. Go to AMIs (left sidebar) and note the AMI ID (ami-xxxxx)

---

## PHASE 8: Create Launch Template

### Step 8.1: Create Launch Template

1. Go to EC2 Console → Launch Templates
2. Click "Create launch template"
3. Configure:
   ```
   Launch template name: moneyone-backend-template
   Template version description: v1
   ```

4. Application and OS Images:
   - Select "My AMIs"
   - Choose "moneyone-backend-v1" (the AMI you just created)

5. Instance type:
   - For production: `t3.medium`
   - For testing: `t3.small`

6. Key pair: Select your existing key pair

7. Network settings:
   - Don't include in launch template (we'll set in Auto Scaling Group)

8. Security groups:
   - Select your EC2 security group

9. Advanced details:
   - IAM instance profile: (leave blank for now)
   - User data: (leave blank, your AMI already has everything)

10. Click "Create launch template"

---

## PHASE 9: Create Auto Scaling Group

### Step 9.1: Create Auto Scaling Group

1. Go to EC2 Console → Auto Scaling Groups
2. Click "Create Auto Scaling group"

3. Step 1 - Choose launch template:
   ```
   Auto Scaling group name: moneyone-backend-asg
   Launch template: moneyone-backend-template
   Version: Latest
   ```
   Click "Next"

4. Step 2 - Network:
   ```
   VPC: [Your VPC]
   Availability Zones and subnets: Select 2 or more subnets
   ```
   Click "Next"

5. Step 3 - Load balancing:
   ```
   ✓ Attach to an existing load balancer
   Choose from your load balancer target groups
   Select: moneyone-backend-tg
   
   Health checks:
   ✓ Turn on Elastic Load Balancing health checks
   Health check grace period: 300 seconds
   ```
   Click "Next"

6. Step 4 - Group size and scaling:
   ```
   Desired capacity: 2
   Minimum capacity: 2
   Maximum capacity: 10
   
   Scaling policies:
   ✓ Target tracking scaling policy
   Scaling policy name: cpu-scaling
   Metric type: Average CPU utilization
   Target value: 70
   ```
   Click "Next"

7. Step 5 - Notifications: Skip (click "Next")

8. Step 6 - Tags:
   ```
   Key: Name, Value: moneyone-backend
   Key: Environment, Value: production
   ```
   Click "Next"

9. Step 7 - Review and create
   - Review all settings
   - Click "Create Auto Scaling group"

### Step 9.2: Wait for Instances

Wait 5-10 minutes for Auto Scaling to launch 2 instances:
- Go to EC2 Console → Instances
- You should see 2 new instances with name "moneyone-backend"

### Step 9.3: Verify Load Balancer

1. Go to Target Groups → moneyone-backend-tg
2. Click "Targets" tab
3. You should see 2-3 targets (your instances)
4. Wait until Status shows "healthy" for all

---

## PHASE 10: Test Load Balancing

### Step 10.1: Test ALB Endpoint

```bash
# Test health endpoint
curl http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com/health

# Test multiple times to see different instances responding
for i in {1..10}; do
  curl http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com/health
  echo ""
done
```

### Step 10.2: Update Your Domain DNS

If you have a domain (e.g., moneyone.com):

1. Go to your domain registrar (GoDaddy, Namecheap, etc.)
2. Update DNS records:
   ```
   Type: CNAME
   Name: api (or @)
   Value: moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com
   TTL: 300
   ```
3. Wait 5-30 minutes for DNS propagation

### Step 10.3: Update Frontend Configuration

Update your frontend .env files:

**moneyone_admin/.env:**
```env
REACT_APP_API_URL=http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com
```

**moneyone_client/.env:**
```env
REACT_APP_API_URL=http://moneyone-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com
```

Rebuild and redeploy frontends.

---

## PHASE 11: Test Auto Scaling

### Step 11.1: Simulate High Load

SSH to any instance and install stress tool:
```bash
sudo apt install stress -y

# Create CPU load
stress --cpu 4 --timeout 300s
```

### Step 11.2: Monitor Scaling

1. Go to EC2 Console → Auto Scaling Groups
2. Click "moneyone-backend-asg"
3. Click "Activity" tab
4. Watch for scaling activities
5. Go to Instances - you should see new instances launching

### Step 11.3: Monitor CloudWatch

1. Go to CloudWatch Console
2. Click "Dashboards" → "Create dashboard"
3. Add widgets for:
   - ALB Request Count
   - Target Response Time
   - Auto Scaling Group CPU
   - Healthy/Unhealthy Host Count

---

## PHASE 12: Cleanup Old Setup

### Step 12.1: Verify Everything Works

Before cleanup, verify:
- [ ] Application loads via ALB
- [ ] Login works
- [ ] Transactions work
- [ ] All APIs respond correctly
- [ ] Auto Scaling works
- [ ] Database queries work

### Step 12.2: Stop Old MySQL (Optional)

If everything works with RDS:
```bash
# SSH to original EC2
sudo systemctl stop mysql
sudo systemctl disable mysql

# Keep old database as backup for 1 week
# Don't delete yet!
```

### Step 12.3: Terminate Original EC2 (After 1 week)

Once you're confident:
1. Go to EC2 Console → Instances
2. Select your original instance
3. Instance state → Terminate instance

---

## PHASE 13: Security Hardening

### Step 13.1: Remove Public RDS Access

1. Go to RDS Console → Databases
2. Click "moneyone-db"
3. Click "Modify"
4. Connectivity → Public access: No
5. Click "Continue"
6. Apply immediately: Yes
7. Click "Modify DB instance"

### Step 13.2: Update RDS Security Group

1. Go to EC2 Console → Security Groups
2. Find "moneyone-rds-sg"
3. Edit inbound rules
4. Remove the "My IP" rule (temporary one)
5. Keep only the EC2 security group rule

### Step 13.3: Enable SSL for ALB (Recommended)

1. Request SSL certificate in AWS Certificate Manager
2. Add HTTPS listener to ALB
3. Redirect HTTP to HTTPS

---

## PHASE 14: Monitoring and Alerts

### Step 14.1: Create CloudWatch Alarms

```bash
# High CPU Alarm
aws cloudwatch put-metric-alarm \
  --alarm-name moneyone-high-cpu \
  --alarm-description "CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# High Error Rate
aws cloudwatch put-metric-alarm \
  --alarm-name moneyone-high-errors \
  --alarm-description "High 5xx errors" \
  --metric-name HTTPCode_Target_5XX_Count \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

### Step 14.2: Set Up SNS for Notifications

1. Go to SNS Console
2. Create topic: "moneyone-alerts"
3. Create subscription with your email
4. Update alarms to send to this topic

---

## Cost Breakdown

### Monthly Costs (Approximate):

**Production Setup:**
- RDS db.t3.medium (Multi-AZ): $120
- EC2 t3.medium × 2-3 instances: $60-90
- Application Load Balancer: $25
- Data transfer: $10-20
- **Total: ~$215-255/month**

**Budget Setup:**
- RDS db.t3.small: $40
- EC2 t3.small × 2 instances: $30
- Application Load Balancer: $25
- **Total: ~$95/month**

---

## Troubleshooting

### Issue 1: Can't Connect to RDS
```bash
# Check security group
# Check VPC settings
# Verify endpoint is correct
# Test with telnet
telnet moneyone-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com 3306
```

### Issue 2: Targets Unhealthy
```bash
# Check health endpoint works
curl http://localhost:5000/health

# Check security group allows ALB
# Check application logs
journalctl -u moneyone-backend -f
```

### Issue 3: Auto Scaling Not Working
- Check CloudWatch metrics
- Verify scaling policies
- Check instance limits in your AWS account

---

## Next Steps

1. Set up SSL certificate
2. Configure CloudFront CDN
3. Set up automated backups
4. Implement Redis caching
5. Set up CI/CD pipeline
6. Configure monitoring dashboard

---

## Important Commands Reference

```bash
# Check RDS connection
mysql -h [RDS-ENDPOINT] -u admin -p

# Check backend logs
journalctl -u moneyone-backend -f

# Restart backend
sudo systemctl restart moneyone-backend

# Check Auto Scaling status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names moneyone-backend-asg

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn [TARGET-GROUP-ARN]
```

---

## Support Checklist

Before asking for help, check:
- [ ] RDS is accessible from EC2
- [ ] Backend .env has correct RDS endpoint
- [ ] Security groups allow traffic
- [ ] Health endpoint returns 200
- [ ] Target group shows healthy targets
- [ ] ALB DNS resolves
- [ ] Application logs show no errors

---

**Congratulations!** You now have a production-ready, auto-scaling payment gateway system! 🎉
