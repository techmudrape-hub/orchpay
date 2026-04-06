# Complete Dozzle Setup Guide - Zero Permission Errors

**Project:** MoneyOne Backend  
**Goal:** Set up Dozzle log monitoring with proper permissions  
**Time:** 15 minutes  
**Difficulty:** Beginner-friendly  

---

## Overview

This guide sets up Dozzle (a beautiful Docker-based log viewer) for your MoneyOne project with:
- ✅ Proper file permissions
- ✅ Automated setup scripts
- ✅ Real-time log monitoring
- ✅ Web-based log viewer
- ✅ System monitoring tools

---

## Prerequisites Check

Before starting, verify you have:

```bash
# Check if you're in the right directory
pwd
# Should show: /var/www/moneyone/moneyone or similar

# Check if backend exists
ls -la backend/
# Should show app.py and other backend files

# Check current user
whoami
# Note your username (usually 'ubuntu' or 'ec2-user')
```

---

## Step 1: Install Docker (If Not Installed)

```bash
# Check if Docker is installed
docker --version

# If not installed, install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (IMPORTANT for permissions)
sudo usermod -aG docker $USER

# Apply group changes immediately
newgrp docker

# Verify Docker works without sudo
docker ps
```

**⚠️ Important:** If you get permission errors, log out and back in, then run `docker ps` again.

---

## Step 2: Run Automated Setup

We have pre-built scripts that handle everything:

```bash
# Make setup script executable
chmod +x setup_dozzle_monitoring.sh

# Run the setup (this handles all permissions automatically)
./setup_dozzle_monitoring.sh
```

**What this script does:**
- ✅ Installs Docker if needed
- ✅ Creates log directories with correct permissions
- ✅ Starts Dozzle container
- ✅ Installs system monitoring tools
- ✅ Creates monitoring scripts

---

## Step 3: Configure Backend Logging

```bash
# Make logging configuration script executable
chmod +x configure_backend_logging.sh

# Run the logging configuration
./configure_backend_logging.sh

# Go to backend directory
cd backend

# Apply logging automatically (recommended)
python3 apply_logging_patch.py
```

**If automatic patching fails, apply manually:**

1. Open `backend/app.py`
2. Add these imports after existing imports:
```python
from logging_setup import setup_logging
from logging_middleware import log_requests
```

3. Add after `jwt = JWTManager(app)`:
```python
# Setup enhanced logging
setup_logging(app)
log_requests(app)
app.logger.info("="*50)
app.logger.info("MoneyOne Backend Starting...")
app.logger.info("="*50)
```

---

## Step 4: Fix File Permissions (Critical Step)

```bash
# Go back to project root
cd ..

# Fix all permissions for logs directory
sudo chown -R $USER:$USER backend/logs/
chmod -R 755 backend/logs/

# Ensure Dozzle can read the logs
sudo chmod -R 644 backend/logs/*.log 2>/dev/null || true

# Fix Docker socket permissions (if needed)
sudo chmod 666 /var/run/docker.sock
```

---

## Step 5: Open AWS Security Group Port

**In AWS Console:**

1. Go to EC2 → Security Groups
2. Find your instance's security group
3. Edit Inbound Rules → Add Rule
4. **Type:** Custom TCP
5. **Port:** 8080
6. **Source:** 0.0.0.0/0 (or your IP for security)
7. **Save Rules**

**Or via AWS CLI:**
```bash
# Get your security group ID first
aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text

# Replace YOUR_SG_ID with actual ID
aws ec2 authorize-security-group-ingress --group-id YOUR_SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0
```

---

## Step 6: Restart Backend Service

Choose the method that matches your setup:

**Method A - Systemd Service:**
```bash
sudo systemctl restart backend
sudo systemctl status backend
```

**Method B - Direct Python Process:**
```bash
# Find and kill existing process
pkill -f "python.*app.py"

# Start new process
cd backend
nohup python3 app.py > /dev/null 2>&1 &
```

**Method C - Gunicorn/uWSGI:**
```bash
sudo systemctl restart gunicorn
# OR
sudo systemctl restart uwsgi
```

---

## Step 7: Verify Everything Works

### Check Dozzle Container:
```bash
docker ps | grep dozzle
# Should show: dozzle container running on port 8080
```

### Check Log Files:
```bash
ls -la backend/logs/
# Should show: app.log, error.log, api_requests.log, transactions.log
```

### Test Logging:
```bash
# Make a test request to your backend
curl http://localhost:5000/health

# Check if logs are created
tail -10 backend/logs/app.log
```

### Get Your Public IP:
```bash
curl ifconfig.me
```

---

## Step 8: Access Dozzle Web Interface

1. **Open browser:** `http://YOUR_PUBLIC_IP:8080`
2. **You should see:** Dozzle interface with log files listed
3. **Click on:** `backend/app.log` to view real-time logs

**Expected Interface:**
- Left sidebar: List of log files
- Main area: Real-time log viewer
- Top bar: Search, filter, and download options

---

## Step 9: Test Real-Time Logging

### Make API Requests:
```bash
# Test different endpoints
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"adminId":"test","password":"test"}'

curl http://localhost:5000/api/health
```

### Watch Logs in Dozzle:
1. Open Dozzle in browser
2. Click on `backend/app.log`
3. You should see requests appearing in real-time!

---

## Troubleshooting Common Issues

### Issue 1: Permission Denied Errors

```bash
# Fix Docker permissions
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker $USER
newgrp docker

# Fix log file permissions
sudo chown -R $USER:$USER backend/logs/
chmod -R 755 backend/logs/
```

### Issue 2: Dozzle Not Starting

```bash
# Check Docker logs
docker logs dozzle

# Restart Dozzle
docker restart dozzle

# If still failing, remove and recreate
docker stop dozzle
docker rm dozzle
./setup_dozzle_monitoring.sh
```

### Issue 3: No Logs Appearing

```bash
# Check if log files exist
ls -la backend/logs/

# Check file permissions
ls -la backend/logs/*.log

# Test manual logging
echo "Test log entry" >> backend/logs/app.log

# Check in Dozzle - should appear immediately
```

### Issue 4: Can't Access Dozzle Web Interface

```bash
# Check if port 8080 is open
sudo netstat -tulpn | grep 8080

# Check firewall
sudo ufw status

# Allow port if needed
sudo ufw allow 8080

# Check AWS Security Group (most common issue)
```

### Issue 5: Backend Won't Start After Changes

```bash
# Check for syntax errors
cd backend
python3 -m py_compile app.py

# Check what's using port 5000
sudo netstat -tulpn | grep 5000

# View detailed error logs
python3 app.py
```

---

## System Monitoring Commands

### Quick Health Check:
```bash
./monitor_system.sh
```

### Detailed Monitoring:
```bash
# Interactive process monitor
htop

# Comprehensive system stats
glances

# Docker container status
docker ps

# Backend process status
ps aux | grep "python.*app.py"
```

### Log Management:
```bash
# View recent logs
tail -50 backend/logs/app.log

# Follow logs in real-time (terminal)
tail -f backend/logs/app.log

# Search for errors
grep ERROR backend/logs/app.log

# Search for specific transaction
grep "TXN123456" backend/logs/app.log

# View error logs only
tail -50 backend/logs/error.log
```

---

## Dozzle Features Guide

### Search Functionality:
- **Search box:** Type keywords to filter logs
- **Examples:**
  - `ERROR` - Find all errors
  - `merchant_id:9000000001` - Find specific merchant
  - `POST /api/payin` - Find API calls
  - `TXN123456` - Find transaction ID

### Filter Options:
- **Level filter:** INFO, WARNING, ERROR
- **Time range:** Last hour, day, week
- **Container filter:** Select specific log files

### Download Logs:
- **Download icon:** Export filtered logs as text file
- **Useful for:** Sharing logs with team, offline analysis

### Real-time Updates:
- **Auto-scroll:** Automatically shows new log entries
- **Pause:** Click pause to stop auto-scrolling
- **Refresh:** Manual refresh if needed

---

## Adding More Logging to Your Code

### In Route Handlers:
```python
@app.route('/api/payin', methods=['POST'])
def create_payin():
    try:
        app.logger.info(f"Payin request from merchant: {merchant_id}")
        
        # Your payment processing code
        
        app.logger.info(f"Payin successful: {transaction_id}")
        return jsonify({"status": "success"})
        
    except Exception as e:
        app.logger.error(f"Payin failed: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500
```

### Transaction Logging:
```python
from logging_setup import log_transaction

# In payment processing
log_transaction(
    transaction_type='PAYIN',
    transaction_id=txn_id,
    merchant_id=merchant_id,
    amount=amount,
    status='SUCCESS',
    details='Processed via Mudrape'
)
```

### Debug Logging:
```python
# Temporary debug logs (remove in production)
app.logger.debug(f"Debug: Processing data: {data}")

# Warning for unusual conditions
if balance < 100:
    app.logger.warning(f"Low balance warning: {balance}")
```

---

## Security Considerations

### Production Setup:
1. **Restrict Dozzle access:**
   - Change Security Group to allow only your IP
   - Use VPN or bastion host for access

2. **Log rotation:**
   - Logs automatically rotate (configured in logging_setup.py)
   - Old logs are compressed and deleted

3. **Sensitive data:**
   - Never log passwords, API keys, or PII
   - Use `[REDACTED]` for sensitive fields

### Example Secure Logging:
```python
# ❌ Don't do this
app.logger.info(f"Login: {username} with password {password}")

# ✅ Do this instead
app.logger.info(f"Login attempt: {username} from {ip_address}")
```

---

## Maintenance Commands

### Daily Maintenance:
```bash
# Check system health
./monitor_system.sh

# Check Dozzle status
docker ps | grep dozzle

# Check log file sizes
du -sh backend/logs/*
```

### Weekly Maintenance:
```bash
# Clean old Docker images
docker system prune -f

# Check disk space
df -h

# Restart Dozzle (if needed)
docker restart dozzle
```

### Log Cleanup (if needed):
```bash
# Compress old logs (automatic, but manual if needed)
gzip backend/logs/app.log.1

# Remove very old logs (be careful!)
find backend/logs/ -name "*.log.*" -mtime +30 -delete
```

---

## Quick Reference Commands

### Dozzle Management:
```bash
docker ps | grep dozzle          # Check status
docker logs dozzle               # View Dozzle logs
docker restart dozzle            # Restart Dozzle
docker stop dozzle               # Stop Dozzle
docker start dozzle              # Start Dozzle
```

### Backend Management:
```bash
sudo systemctl status backend    # Check backend status
sudo systemctl restart backend   # Restart backend
tail -f backend/logs/app.log     # Follow logs
ps aux | grep "python.*app.py"   # Find backend process
```

### System Monitoring:
```bash
./monitor_system.sh              # Quick health check
htop                             # Interactive process monitor
glances                          # Detailed system stats
df -h                            # Disk usage
free -h                          # Memory usage
```

---

## Success Checklist

After completing this guide, you should have:

- ✅ Dozzle running at `http://YOUR_IP:8080`
- ✅ Real-time log viewing in web browser
- ✅ Backend logging to multiple log files
- ✅ Automatic log rotation
- ✅ System monitoring tools installed
- ✅ No permission errors
- ✅ Proper security group configuration
- ✅ Search and filter functionality in logs

---

## What's Next?

1. **Monitor your application:** Watch logs during normal operation
2. **Set up alerts:** Use log patterns to detect issues
3. **Performance monitoring:** Add timing logs to slow operations
4. **Error tracking:** Monitor error.log for issues
5. **Transaction monitoring:** Use transactions.log for payment tracking

---

## Support

If you encounter issues:

1. **Check troubleshooting section above**
2. **Run:** `./monitor_system.sh` for system status
3. **Check:** `docker logs dozzle` for Dozzle issues
4. **Verify:** AWS Security Group has port 8080 open
5. **Test:** `curl http://localhost:8080` on server

**Common Success Indicators:**
- Dozzle web interface loads
- Log files appear in Dozzle
- Real-time updates work
- Search functionality works
- No permission errors in any commands

---

**Setup Complete! 🎉**

Your MoneyOne backend now has professional-grade log monitoring with zero permission issues.