# Complete Performance Fix Guide

## Current Issues Identified

1. ✅ RDS upgraded to db.t4g.medium (max_connections: 240)
2. ✅ Connection pooling enabled with DBUtils
3. ❌ **Only 1 Gunicorn worker** (handles 1 request at a time)
4. ❌ **1 unhealthy target** in load balancer (Request timed out)
5. ⚠️ Instance may be overloaded

## Immediate Actions Required

### 1. Increase Gunicorn Workers (CRITICAL)

```bash
# SSH to your server
ssh ubuntu@your-server-ip

# Edit the systemd service file
sudo nano /etc/systemd/system/moneyone-api.service

# Change this line:
# --workers 1
# To:
# --workers 4

# The line should look like:
ExecStart=/var/www/moneyone/moneyone/backend/venv/bin/gunicorn --workers 4 --worker-class sync --bind 0.0.0.0:5000 --timeout 120 --access-logfile /var/log/moneyone/access.log --error-logfile /var/log/moneyone/error.log app:app

# Save and exit (Ctrl+X, Y, Enter)

# Reload systemd and restart service
sudo systemctl daemon-reload
sudo systemctl restart moneyone-api

# Verify it's running
sudo systemctl status moneyone-api
```

### 2. Check Instance Health

```bash
# Check CPU and memory usage
top

# Check if instance is overloaded
htop  # If installed

# Check disk space
df -h

# Check memory
free -h
```

### 3. Fix Unhealthy Target

The unhealthy target is causing timeouts. This could be due to:

**Option A: Restart the unhealthy instance**
```bash
# From AWS Console:
# EC2 > Instances > Select unhealthy instance > Instance State > Reboot
```

**Option B: Deregister and re-register the target**
```bash
# From AWS Console:
# EC2 > Target Groups > moneyone-backend-tg > Targets tab
# Select unhealthy target > Actions > Deregister
# Wait 30 seconds
# Actions > Register targets > Select instance > Register
```

### 4. Optimize Connection Pool Settings

Your current pool settings:
- maxconnections=50 (too high for 1 worker)
- mincached=10
- maxcached=20

With 4 workers, this is better, but let's optimize:

```python
# Recommended settings for 4 workers:
maxconnections=20,        # 5 connections per worker
mincached=4,              # 1 per worker
maxcached=8,              # 2 per worker
```

### 5. Add Database Indexes (If Not Done)

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python add_indexes_safe.py
```

## Recommended Worker Configuration

For c7i.flex.large (2 vCPU, 4GB RAM):
- **Workers: 4** (formula: 2 * CPU + 1 = 2 * 2 + 1 = 5, but 4 is safer)
- **Worker class: sync** (current, good for your use case)
- **Timeout: 120** (current, good)

## Performance Monitoring

### Check if workers are running:
```bash
ps aux | grep gunicorn
# Should show 1 master + 4 worker processes
```

### Monitor logs:
```bash
tail -f /var/log/moneyone/error.log
tail -f /var/log/moneyone/access.log
```

### Check database connections:
```bash
# Connect to RDS
mysql -h your-rds-endpoint -u admin -p

# Check active connections
SHOW PROCESSLIST;
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';
```

## Expected Results After Fix

1. ✅ 4 Gunicorn workers handling concurrent requests
2. ✅ Dashboard loads quickly even during traffic
3. ✅ All targets healthy in load balancer
4. ✅ Response times under 2 seconds

## If Still Slow After These Changes

### Option 1: Increase Instance Size
Current: c7i.flex.large (2 vCPU, 4GB RAM)
Upgrade to: c7i.flex.xlarge (4 vCPU, 8GB RAM)
- This would allow 8-10 workers

### Option 2: Add More Instances
- Keep current instance size
- Add 1-2 more instances behind load balancer
- Distribute traffic across multiple servers

### Option 3: Enable Caching
- Add Redis for session management
- Cache frequently accessed data
- Reduce database queries

## Quick Verification Commands

```bash
# 1. Check workers
ps aux | grep gunicorn | wc -l
# Should show 5 (1 master + 4 workers)

# 2. Check service status
sudo systemctl status moneyone-api

# 3. Test endpoint
curl http://localhost:5000/api/admin/verify

# 4. Check load balancer health
# AWS Console > EC2 > Target Groups > Check all targets are healthy
```

## Troubleshooting

### If service fails to start:
```bash
# Check logs
sudo journalctl -u moneyone-api -n 50

# Common issue: DBUtils not installed in venv
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install DBUtils
sudo systemctl restart moneyone-api
```

### If still getting timeouts:
```bash
# Increase timeout in service file
sudo nano /etc/systemd/system/moneyone-api.service
# Change --timeout 120 to --timeout 180

sudo systemctl daemon-reload
sudo systemctl restart moneyone-api
```

## Next Steps

1. Increase workers to 4 (IMMEDIATE)
2. Fix unhealthy target (IMMEDIATE)
3. Monitor for 1 hour
4. If still slow, consider scaling up instance or adding more instances
