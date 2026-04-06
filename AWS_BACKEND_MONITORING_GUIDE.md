# AWS Backend Monitoring & Health Check Guide

## Complete Guide to Monitor MoneyOne Backend on AWS EC2

---

## Table of Contents
1. [Quick Health Check](#quick-health-check)
2. [System Resource Monitoring](#system-resource-monitoring)
3. [Application Monitoring](#application-monitoring)
4. [Database Monitoring](#database-monitoring)
5. [Log Analysis](#log-analysis)
6. [API Endpoint Testing](#api-endpoint-testing)
7. [Payment Gateway Monitoring](#payment-gateway-monitoring)
8. [Security Monitoring](#security-monitoring)
9. [Automated Monitoring Scripts](#automated-monitoring-scripts)
10. [Troubleshooting Guide](#troubleshooting-guide)

---

## 1. Quick Health Check

### 1.1 SSH into EC2 Instance
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### 1.2 Check Backend Service Status
```bash
# Check if Flask app is running
ps aux | grep python
ps aux | grep gunicorn

# Check process count
ps aux | grep python | wc -l

# Check if port 5000 is listening
sudo netstat -tulpn | grep :5000
# OR
sudo lsof -i :5000
```

### 1.3 Quick API Health Check
```bash
# Test backend health endpoint
curl http://localhost:5000/api/health

# Test with full URL
curl https://api.orchpay.in/api/health

# Check response time
time curl http://localhost:5000/api/health
```

---

## 2. System Resource Monitoring

### 2.1 CPU Usage
```bash
# Real-time CPU monitoring
top

# CPU usage summary
mpstat 1 5

# Per-process CPU usage
ps aux --sort=-%cpu | head -10

# Check CPU load average
uptime
```

### 2.2 Memory Usage
```bash
# Memory overview
free -h

# Detailed memory info
cat /proc/meminfo

# Memory usage by process
ps aux --sort=-%mem | head -10

# Check for memory leaks
watch -n 5 'free -h'
```

### 2.3 Disk Usage
```bash
# Disk space overview
df -h

# Check specific directory sizes
du -sh /home/ubuntu/backend/*
du -sh /var/log/*

# Find large files
find /home/ubuntu -type f -size +100M -exec ls -lh {} \;

# Check inode usage
df -i
```

### 2.4 Network Monitoring
```bash
# Active connections
netstat -an | grep ESTABLISHED | wc -l

# Network traffic
ifconfig
vnstat

# Check bandwidth usage
iftop

# Monitor specific port
sudo tcpdump -i any port 5000
```

---

## 3. Application Monitoring

### 3.1 Check Backend Process
```bash
# Check if backend is running
systemctl status moneyone-backend
# OR if using supervisor
sudo supervisorctl status moneyone-backend

# Check process details
ps aux | grep "python.*app.py"

# Check how long process has been running
ps -eo pid,etime,cmd | grep python
```

### 3.2 Check Application Logs
```bash
# View recent logs
tail -f /home/ubuntu/backend/logs/app.log

# Check error logs
tail -f /home/ubuntu/backend/logs/error.log

# View last 100 lines
tail -n 100 /home/ubuntu/backend/logs/app.log

# Search for errors
grep -i "error" /home/ubuntu/backend/logs/app.log | tail -20

# Search for specific date
grep "2026-03-01" /home/ubuntu/backend/logs/app.log
```

### 3.3 Monitor Active Requests
```bash
# Check active Python processes
ps aux | grep python | grep -v grep

# Monitor request count
tail -f /var/log/nginx/access.log | grep "POST\|GET"

# Count requests per minute
tail -f /var/log/nginx/access.log | awk '{print $4}' | cut -d: -f1-2 | uniq -c
```

### 3.4 Check Environment Variables
```bash
# View backend environment
cat /home/ubuntu/backend/.env

# Check if all required variables are set
grep -E "DATABASE_URL|JWT_SECRET|PAYU_|TOURQUEST_|MUDRAPE_" /home/ubuntu/backend/.env
```

---

## 4. Database Monitoring

### 4.1 PostgreSQL Connection Check
```bash
# Connect to database
psql -h localhost -U your_db_user -d moneyone_db

# Check database size
psql -U your_db_user -d moneyone_db -c "SELECT pg_size_pretty(pg_database_size('moneyone_db'));"

# Check active connections
psql -U your_db_user -d moneyone_db -c "SELECT count(*) FROM pg_stat_activity;"

# View active queries
psql -U your_db_user -d moneyone_db -c "SELECT pid, usename, application_name, client_addr, state, query FROM pg_stat_activity WHERE state != 'idle';"
```

### 4.2 Database Performance
```bash
# Check slow queries
psql -U your_db_user -d moneyone_db -c "SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Check table sizes
psql -U your_db_user -d moneyone_db -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema') ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

# Check index usage
psql -U your_db_user -d moneyone_db -c "SELECT schemaname, tablename, indexname, idx_scan FROM pg_stat_user_indexes ORDER BY idx_scan;"
```

### 4.3 Database Health Check
```bash
# Check for locks
psql -U your_db_user -d moneyone_db -c "SELECT * FROM pg_locks WHERE NOT granted;"

# Check for long-running transactions
psql -U your_db_user -d moneyone_db -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 minutes';"

# Check database statistics
psql -U your_db_user -d moneyone_db -c "SELECT * FROM pg_stat_database WHERE datname = 'moneyone_db';"
```

---

## 5. Log Analysis

### 5.1 Backend Application Logs
```bash
# Real-time log monitoring
tail -f /home/ubuntu/backend/logs/app.log

# Filter by log level
grep "ERROR" /home/ubuntu/backend/logs/app.log | tail -50
grep "WARNING" /home/ubuntu/backend/logs/app.log | tail -50

# Search for specific transaction
grep "TXN123456" /home/ubuntu/backend/logs/app.log

# Count errors by type
grep "ERROR" /home/ubuntu/backend/logs/app.log | awk '{print $5}' | sort | uniq -c | sort -rn
```

### 5.2 Nginx Access Logs
```bash
# View access logs
tail -f /var/log/nginx/access.log

# Count requests by endpoint
awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Check response codes
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Find slow requests (>1 second)
awk '$NF > 1.0 {print $0}' /var/log/nginx/access.log | tail -20
```

### 5.3 Nginx Error Logs
```bash
# View error logs
tail -f /var/log/nginx/error.log

# Count errors by type
grep "error" /var/log/nginx/error.log | awk '{print $8}' | sort | uniq -c | sort -rn

# Check for connection issues
grep "upstream" /var/log/nginx/error.log | tail -20
```

### 5.4 System Logs
```bash
# Check system messages
tail -f /var/log/syslog

# Check authentication logs
tail -f /var/log/auth.log

# Check kernel messages
dmesg | tail -50
```

---

## 6. API Endpoint Testing

### 6.1 Health Check Endpoints
```bash
# Backend health
curl -X GET http://localhost:5000/api/health

# Database connection check
curl -X GET http://localhost:5000/api/db-health

# Check API version
curl -X GET http://localhost:5000/api/version
```

### 6.2 Authentication Testing
```bash
# Test merchant login
curl -X POST http://localhost:5000/api/merchant/login \
  -H "Content-Type: application/json" \
  -d '{
    "merchantId": "TEST_MERCHANT",
    "password": "test_password"
  }'

# Test admin login
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin_password"
  }'
```

### 6.3 PayIN API Testing
```bash
# Test PayIN order creation (with encryption)
curl -X POST http://localhost:5000/api/payin/order/create \
  -H "X-Authorization-Key: your_auth_key" \
  -H "X-Module-Secret: your_module_secret" \
  -H "Content-Type: application/json" \
  -d '{
    "data": "encrypted_payload_here"
  }'

# Test transaction status
curl -X POST http://localhost:5000/api/payin/transaction/status \
  -H "X-Authorization-Key: your_auth_key" \
  -H "X-Module-Secret: your_module_secret" \
  -H "Content-Type: application/json" \
  -d '{
    "data": "encrypted_txn_id"
  }'
```

### 6.4 PayOUT API Testing
```bash
# Get bearer token first
TOKEN=$(curl -X POST http://localhost:5000/api/merchant/login \
  -H "Content-Type: application/json" \
  -d '{"merchantId":"TEST","password":"test"}' \
  | jq -r '.token')

# Test payout
curl -X POST http://localhost:5000/api/payout/client/direct-payout \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Authorization-Key: your_auth_key" \
  -H "X-Module-Secret: your_module_secret" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "TEST_ORDER_123",
    "amount": 100.00,
    "tpin": "1234",
    "account_holder_name": "Test User",
    "account_number": "1234567890",
    "ifsc_code": "SBIN0001234",
    "bank_name": "State Bank of India",
    "payment_type": "IMPS"
  }'

# Check payout status
curl -X POST http://localhost:5000/api/payout/client/check-status/TXN123 \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Authorization-Key: your_auth_key" \
  -H "X-Module-Secret: your_module_secret" \
  -H "Content-Type: application/json"
```

### 6.5 Response Time Testing
```bash
# Measure API response time
time curl -X GET http://localhost:5000/api/health

# Test multiple requests
for i in {1..10}; do
  time curl -s -o /dev/null -w "%{time_total}\n" http://localhost:5000/api/health
done

# Average response time
ab -n 100 -c 10 http://localhost:5000/api/health
```

---

## 7. Payment Gateway Monitoring

### 7.1 Check Gateway Connectivity
```bash
# Test PayU connectivity
curl -X POST https://test.payu.in/merchant/postservice?form=2 \
  -d "key=your_key&command=verify_payment&var1=txn_id"

# Test TourQuest connectivity
curl -X POST https://tourquest-api-url/status \
  -H "Content-Type: application/json" \
  -d '{"txn_id": "test"}'

# Test Mudrape connectivity
curl -X POST https://mudrape-api-url/check-status \
  -H "Content-Type: application/json" \
  -d '{"order_id": "test"}'
```

### 7.2 Monitor Callback Processing
```bash
# Check recent callbacks
tail -f /home/ubuntu/backend/logs/app.log | grep "callback"

# Count callbacks by status
grep "callback" /home/ubuntu/backend/logs/app.log | grep -o "status: [A-Z]*" | sort | uniq -c

# Check failed callbacks
grep "callback.*failed" /home/ubuntu/backend/logs/app.log | tail -20

# Monitor callback queue
psql -U your_db_user -d moneyone_db -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'PENDING' AND created_at > NOW() - INTERVAL '1 hour';"
```

### 7.3 Check Gateway Response Times
```bash
# Monitor gateway API calls in logs
grep "gateway_api_call" /home/ubuntu/backend/logs/app.log | tail -20

# Check for timeout errors
grep "timeout\|TimeoutError" /home/ubuntu/backend/logs/app.log | tail -20

# Monitor gateway errors
grep "gateway.*error" /home/ubuntu/backend/logs/app.log | tail -20
```

---

## 8. Security Monitoring

### 8.1 Check Failed Login Attempts
```bash
# Check failed logins in application
grep "login.*failed\|Invalid credentials" /home/ubuntu/backend/logs/app.log | tail -20

# Count failed attempts by IP
grep "login.*failed" /home/ubuntu/backend/logs/app.log | grep -oP '\d+\.\d+\.\d+\.\d+' | sort | uniq -c | sort -rn

# Check SSH failed attempts
grep "Failed password" /var/log/auth.log | tail -20
```

### 8.2 Monitor Suspicious Activity
```bash
# Check for SQL injection attempts
grep -i "select.*from\|union.*select\|drop.*table" /var/log/nginx/access.log | tail -20

# Check for unusual request patterns
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Monitor rate limiting
grep "rate limit" /var/log/nginx/error.log | tail -20
```

### 8.3 SSL/TLS Certificate Check
```bash
# Check certificate expiry
echo | openssl s_client -servername api.orchpay.in -connect api.orchpay.in:443 2>/dev/null | openssl x509 -noout -dates

# Check certificate details
echo | openssl s_client -servername api.orchpay.in -connect api.orchpay.in:443 2>/dev/null | openssl x509 -noout -text

# Verify SSL configuration
curl -vI https://api.orchpay.in 2>&1 | grep -i ssl
```

### 8.4 Firewall and Security Groups
```bash
# Check firewall rules
sudo ufw status verbose

# Check iptables rules
sudo iptables -L -n -v

# Check open ports
sudo netstat -tulpn | grep LISTEN
```

---

## 9. Automated Monitoring Scripts

### 9.1 Create Health Check Script
```bash
#!/bin/bash
# File: /home/ubuntu/scripts/health_check.sh

echo "=== MoneyOne Backend Health Check ==="
echo "Date: $(date)"
echo ""

# Check backend process
echo "1. Backend Process Status:"
if ps aux | grep -q "[p]ython.*app.py"; then
    echo "✓ Backend is running"
    ps aux | grep "[p]ython.*app.py" | awk '{print "  PID:", $2, "CPU:", $3"%", "MEM:", $4"%"}'
else
    echo "✗ Backend is NOT running"
fi
echo ""

# Check API health
echo "2. API Health:"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/health)
if [ "$HEALTH" = "200" ]; then
    echo "✓ API is responding (HTTP $HEALTH)"
else
    echo "✗ API is not responding properly (HTTP $HEALTH)"
fi
echo ""

# Check database
echo "3. Database Connection:"
if psql -U your_db_user -d moneyone_db -c "SELECT 1" > /dev/null 2>&1; then
    echo "✓ Database is accessible"
    CONN_COUNT=$(psql -U your_db_user -d moneyone_db -t -c "SELECT count(*) FROM pg_stat_activity;")
    echo "  Active connections: $CONN_COUNT"
else
    echo "✗ Database connection failed"
fi
echo ""

# Check disk space
echo "4. Disk Space:"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "✓ Disk usage: ${DISK_USAGE}%"
else
    echo "⚠ Warning: Disk usage is high: ${DISK_USAGE}%"
fi
echo ""

# Check memory
echo "5. Memory Usage:"
MEM_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
if [ "$MEM_USAGE" -lt 80 ]; then
    echo "✓ Memory usage: ${MEM_USAGE}%"
else
    echo "⚠ Warning: Memory usage is high: ${MEM_USAGE}%"
fi
echo ""

# Check recent errors
echo "6. Recent Errors (last 10):"
ERROR_COUNT=$(grep -c "ERROR" /home/ubuntu/backend/logs/app.log 2>/dev/null || echo "0")
echo "  Total errors in log: $ERROR_COUNT"
if [ -f /home/ubuntu/backend/logs/app.log ]; then
    grep "ERROR" /home/ubuntu/backend/logs/app.log | tail -5
fi
echo ""

echo "=== Health Check Complete ==="
```

### 9.2 Create Transaction Monitor Script
```bash
#!/bin/bash
# File: /home/ubuntu/scripts/transaction_monitor.sh

echo "=== Transaction Monitoring ==="
echo "Date: $(date)"
echo ""

# PayIN transactions
echo "1. PayIN Transactions (Last 1 hour):"
psql -U your_db_user -d moneyone_db -c "
SELECT 
    status, 
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM payin_transactions 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY status;
"
echo ""

# PayOUT transactions
echo "2. PayOUT Transactions (Last 1 hour):"
psql -U your_db_user -d moneyone_db -c "
SELECT 
    status, 
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM payout_transactions 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY status;
"
echo ""

# Pending transactions
echo "3. Pending Transactions:"
PENDING_PAYIN=$(psql -U your_db_user -d moneyone_db -t -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'PENDING' AND created_at > NOW() - INTERVAL '24 hours';")
PENDING_PAYOUT=$(psql -U your_db_user -d moneyone_db -t -c "SELECT COUNT(*) FROM payout_transactions WHERE status IN ('INITIATED', 'QUEUED', 'INPROCESS') AND created_at > NOW() - INTERVAL '24 hours';")

echo "  PayIN Pending: $PENDING_PAYIN"
echo "  PayOUT Pending: $PENDING_PAYOUT"
echo ""

# Failed transactions
echo "4. Failed Transactions (Last 1 hour):"
FAILED_PAYIN=$(psql -U your_db_user -d moneyone_db -t -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'FAILED' AND created_at > NOW() - INTERVAL '1 hour';")
FAILED_PAYOUT=$(psql -U your_db_user -d moneyone_db -t -c "SELECT COUNT(*) FROM payout_transactions WHERE status = 'FAILED' AND created_at > NOW() - INTERVAL '1 hour';")

echo "  PayIN Failed: $FAILED_PAYIN"
echo "  PayOUT Failed: $FAILED_PAYOUT"

if [ "$FAILED_PAYIN" -gt 10 ] || [ "$FAILED_PAYOUT" -gt 10 ]; then
    echo "  ⚠ Warning: High failure rate detected!"
fi
echo ""

echo "=== Monitoring Complete ==="
```

### 9.3 Create Log Rotation Script
```bash
#!/bin/bash
# File: /home/ubuntu/scripts/rotate_logs.sh

LOG_DIR="/home/ubuntu/backend/logs"
ARCHIVE_DIR="/home/ubuntu/backend/logs/archive"
DAYS_TO_KEEP=30

# Create archive directory if it doesn't exist
mkdir -p $ARCHIVE_DIR

# Rotate application logs
if [ -f "$LOG_DIR/app.log" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    gzip -c "$LOG_DIR/app.log" > "$ARCHIVE_DIR/app_$TIMESTAMP.log.gz"
    > "$LOG_DIR/app.log"
    echo "Rotated app.log"
fi

# Delete old archives
find $ARCHIVE_DIR -name "*.log.gz" -mtime +$DAYS_TO_KEEP -delete
echo "Deleted archives older than $DAYS_TO_KEEP days"
```

### 9.4 Setup Cron Jobs
```bash
# Edit crontab
crontab -e

# Add these lines:

# Health check every 5 minutes
*/5 * * * * /home/ubuntu/scripts/health_check.sh >> /home/ubuntu/logs/health_check.log 2>&1

# Transaction monitoring every 15 minutes
*/15 * * * * /home/ubuntu/scripts/transaction_monitor.sh >> /home/ubuntu/logs/transaction_monitor.log 2>&1

# Log rotation daily at 2 AM
0 2 * * * /home/ubuntu/scripts/rotate_logs.sh >> /home/ubuntu/logs/log_rotation.log 2>&1

# Disk space alert daily at 9 AM
0 9 * * * df -h | mail -s "Disk Space Report" admin@moneyone.co.in
```

---

## 10. Troubleshooting Guide

### 10.1 Backend Not Responding

**Symptoms:**
- API returns 502/504 errors
- Timeout errors
- No response from backend

**Diagnosis:**
```bash
# Check if process is running
ps aux | grep python

# Check port availability
sudo netstat -tulpn | grep :5000

# Check recent errors
tail -50 /home/ubuntu/backend/logs/error.log

# Check system resources
top
free -h
df -h
```

**Solutions:**
```bash
# Restart backend service
sudo systemctl restart moneyone-backend
# OR
sudo supervisorctl restart moneyone-backend

# If process is stuck, kill and restart
pkill -f "python.*app.py"
cd /home/ubuntu/backend
nohup python app.py > logs/app.log 2>&1 &

# Check if it started
ps aux | grep python
curl http://localhost:5000/api/health
```

### 10.2 High Memory Usage

**Diagnosis:**
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head -10

# Check for memory leaks
watch -n 5 'ps aux | grep python | awk "{print \$6}"'
```

**Solutions:**
```bash
# Restart backend to free memory
sudo systemctl restart moneyone-backend

# Increase swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add to /etc/fstab for persistence
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 10.3 Database Connection Issues

**Symptoms:**
- "Connection refused" errors
- "Too many connections" errors
- Slow query performance

**Diagnosis:**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connections
psql -U your_db_user -d moneyone_db -c "SELECT count(*) FROM pg_stat_activity;"

# Check for locks
psql -U your_db_user -d moneyone_db -c "SELECT * FROM pg_locks WHERE NOT granted;"
```

**Solutions:**
```bash
# Restart PostgreSQL
sudo systemctl restart postgresql

# Increase max connections (edit postgresql.conf)
sudo nano /etc/postgresql/*/main/postgresql.conf
# Change: max_connections = 200

# Kill idle connections
psql -U your_db_user -d moneyone_db -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle' AND state_change < NOW() - INTERVAL '10 minutes';"

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### 10.4 Payment Gateway Failures

**Symptoms:**
- Callbacks not received
- Gateway timeout errors
- Transaction stuck in PENDING

**Diagnosis:**
```bash
# Check recent gateway calls
grep "gateway" /home/ubuntu/backend/logs/app.log | tail -20

# Check callback logs
grep "callback" /home/ubuntu/backend/logs/app.log | tail -20

# Check pending transactions
psql -U your_db_user -d moneyone_db -c "SELECT txn_id, status, created_at FROM payin_transactions WHERE status = 'PENDING' AND created_at < NOW() - INTERVAL '30 minutes' ORDER BY created_at DESC LIMIT 10;"
```

**Solutions:**
```bash
# Manually trigger callback check
cd /home/ubuntu/backend
python check_callback_processing.py

# Sync missing UTRs
python sync_missing_utr.py

# Trigger missed callbacks
python trigger_missed_callbacks.py

# Check gateway configuration
python check_callback_config.py
```

### 10.5 SSL Certificate Issues

**Symptoms:**
- HTTPS not working
- Certificate expired warnings
- Mixed content errors

**Diagnosis:**
```bash
# Check certificate expiry
echo | openssl s_client -servername api.orchpay.in -connect api.orchpay.in:443 2>/dev/null | openssl x509 -noout -dates

# Check Nginx SSL configuration
sudo nginx -t
cat /etc/nginx/sites-available/moneyone
```

**Solutions:**
```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Force renewal
sudo certbot renew --force-renewal

# Restart Nginx
sudo systemctl restart nginx

# Check if working
curl -vI https://api.orchpay.in
```

### 10.6 Slow API Response

**Diagnosis:**
```bash
# Check response times
time curl http://localhost:5000/api/health

# Check slow queries
psql -U your_db_user -d moneyone_db -c "SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Check system load
uptime
top
```

**Solutions:**
```bash
# Add database indexes
psql -U your_db_user -d moneyone_db -c "CREATE INDEX IF NOT EXISTS idx_payin_txn_id ON payin_transactions(txn_id);"
psql -U your_db_user -d moneyone_db -c "CREATE INDEX IF NOT EXISTS idx_payout_txn_id ON payout_transactions(txn_id);"

# Optimize database
psql -U your_db_user -d moneyone_db -c "VACUUM ANALYZE;"

# Restart backend
sudo systemctl restart moneyone-backend
```

---

## Quick Reference Commands

### Essential Commands
```bash
# Backend status
sudo systemctl status moneyone-backend

# Restart backend
sudo systemctl restart moneyone-backend

# View logs
tail -f /home/ubuntu/backend/logs/app.log

# Check API
curl http://localhost:5000/api/health

# Database connection
psql -U your_db_user -d moneyone_db

# System resources
top
free -h
df -h

# Network connections
sudo netstat -tulpn | grep :5000
```

### Emergency Commands
```bash
# Kill stuck backend process
pkill -f "python.*app.py"

# Restart all services
sudo systemctl restart moneyone-backend
sudo systemctl restart postgresql
sudo systemctl restart nginx

# Clear logs if disk full
> /home/ubuntu/backend/logs/app.log
> /var/log/nginx/access.log

# Check what's using disk space
du -sh /* | sort -h
```

---

## Monitoring Checklist

### Daily Checks
- [ ] Backend service is running
- [ ] API health endpoint responds
- [ ] Database is accessible
- [ ] Disk space < 80%
- [ ] Memory usage < 80%
- [ ] No critical errors in logs
- [ ] Recent transactions are processing

### Weekly Checks
- [ ] Review error logs
- [ ] Check slow queries
- [ ] Verify backup status
- [ ] Review security logs
- [ ] Check SSL certificate expiry
- [ ] Monitor transaction success rate
- [ ] Review gateway performance

### Monthly Checks
- [ ] Update system packages
- [ ] Review and optimize database
- [ ] Clean old logs
- [ ] Review security policies
- [ ] Performance optimization
- [ ] Capacity planning
- [ ] Disaster recovery test

---

## Contact & Support

### When to Escalate
- Backend down for > 5 minutes
- Database connection failures
- Payment gateway complete failure
- Security breach detected
- Disk space > 90%
- Memory usage > 90%
- High transaction failure rate (> 10%)

### Emergency Contacts
- DevOps Team: devops@moneyone.co.in
- Backend Team: backend@moneyone.co.in
- Database Admin: dba@moneyone.co.in
- Security Team: security@moneyone.co.in

---

**Document Version:** 1.0  
**Last Updated:** March 1, 2026  
**Maintained By:** MoneyOne DevOps Team
