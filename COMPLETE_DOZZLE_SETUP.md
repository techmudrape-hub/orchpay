# Complete Dozzle Setup - Final Steps

## Current Status ✅

1. ✅ Dozzle Docker container is running (port 8080)
2. ✅ `dozzle_logs` folder created at `/var/www/moneyone/moneyone/backend/dozzle_logs`
3. ✅ `app.py` has logging imports added
4. ✅ `enhanced_logging.py` file created locally

---

## What You Need to Do Now

### Step 1: Upload enhanced_logging.py to Server

Copy the `enhanced_logging.py` file to your server:

```bash
# From your local machine (where you have the file)
scp backend/enhanced_logging.py ubuntu@YOUR_EC2_IP:/var/www/moneyone/moneyone/backend/

# OR if you prefer, SSH to server and create it manually:
ssh ubuntu@YOUR_EC2_IP
cd /var/www/moneyone/moneyone/backend
sudo nano enhanced_logging.py
# Then paste the content from backend/enhanced_logging.py
```

### Step 2: Restart Your Backend

SSH to your server and restart the backend:

```bash
ssh ubuntu@YOUR_EC2_IP

# Find your backend process
ps aux | grep "python.*app.py"

# You'll see something like:
# ubuntu   12345  ... python3 app.py

# Kill it (replace 12345 with actual PID)
sudo kill 12345

# OR if using systemd service:
sudo systemctl restart backend

# OR if using gunicorn:
sudo systemctl restart gunicorn

# OR if using supervisor:
sudo supervisorctl restart backend
```

### Step 3: Verify Logging Works

```bash
# Check if log file is created
ls -lh /var/www/moneyone/moneyone/backend/dozzle_logs/

# You should see: app.log

# View the logs
tail -20 /var/www/moneyone/moneyone/backend/dozzle_logs/app.log

# You should see:
# ==================================================
# MoneyOne Backend Started
# ==================================================
```

### Step 4: Open Port 8080 in AWS Security Group

1. Go to AWS Console → EC2 → Instances
2. Click your instance → Security tab
3. Click the security group link
4. Click "Edit inbound rules"
5. Click "Add rule"
6. Configure:
   - Type: Custom TCP
   - Port: 8080
   - Source: 0.0.0.0/0 (or your IP for security)
7. Click "Save rules"

### Step 5: Access Dozzle

Get your EC2 public IP:

```bash
curl ifconfig.me
```

Open in browser:
```
http://YOUR_EC2_IP:8080
```

You should see:
- Dozzle interface
- Your log files listed
- Click on `backend/app.log` to view logs in real-time

---

## Test It

Make some API requests to your backend:

```bash
# From your local machine or server
curl http://YOUR_EC2_IP:5000/api/admin/captcha

# Or test any other endpoint
curl http://YOUR_EC2_IP:5000/health
```

Then check Dozzle - you should see the requests logged in real-time!

---

## Quick Commands

### View Logs Directly

```bash
# Last 50 lines
tail -50 /var/www/moneyone/moneyone/backend/dozzle_logs/app.log

# Follow in real-time
tail -f /var/www/moneyone/moneyone/backend/dozzle_logs/app.log

# Search for errors
grep ERROR /var/www/moneyone/moneyone/backend/dozzle_logs/app.log

# Search for specific transaction
grep "TXN123456" /var/www/moneyone/moneyone/backend/dozzle_logs/app.log
```

### Manage Dozzle

```bash
# Check status
docker ps | grep dozzle

# Restart
docker restart dozzle

# View Dozzle logs
docker logs dozzle

# Stop
docker stop dozzle

# Start
docker start dozzle
```

---

## Troubleshooting

### Backend won't start?

```bash
# Check for import errors
cd /var/www/moneyone/moneyone/backend
python3 -c "from enhanced_logging import setup_app_logging; print('OK')"

# If error, check file exists
ls -lh enhanced_logging.py

# Check file permissions
sudo chmod 644 enhanced_logging.py
```

### No logs appearing?

```bash
# Check directory permissions
sudo chmod 755 /var/www/moneyone/moneyone/backend/dozzle_logs

# Check if backend is writing logs
sudo ls -lh /var/www/moneyone/moneyone/backend/dozzle_logs/

# Manually test logging
cd /var/www/moneyone/moneyone/backend
python3 -c "
from flask import Flask
from enhanced_logging import setup_app_logging
app = Flask(__name__)
setup_app_logging(app)
app.logger.info('Test log')
"
```

### Dozzle not accessible?

```bash
# Check Dozzle is running
docker ps | grep dozzle

# Check port 8080
sudo netstat -tulpn | grep 8080

# Check firewall
sudo ufw status

# Allow port if needed
sudo ufw allow 8080

# Restart Dozzle
docker restart dozzle
```

---

## What You Get

✅ Real-time log viewing in browser  
✅ Search and filter logs easily  
✅ No configuration needed  
✅ Automatic log rotation (keeps last 50MB)  
✅ Request/response logging for all APIs  
✅ Error tracking  
✅ Transaction monitoring  

---

## Next Steps

Once everything is working:

1. Add more detailed logging to your routes:

```python
# In any route
app.logger.info(f"Processing payment for merchant {merchant_id}")
app.logger.warning(f"Low balance: {balance}")
app.logger.error(f"Payment failed: {error}")
```

2. Use Dozzle to:
   - Monitor API requests in real-time
   - Search for specific transactions
   - Debug errors
   - Track merchant activities

3. Bookmark Dozzle URL for quick access

---

## Summary

You're almost done! Just:

1. Upload `enhanced_logging.py` to server
2. Restart backend
3. Open port 8080 in AWS
4. Access Dozzle at `http://YOUR_EC2_IP:8080`

That's it! 🎉
