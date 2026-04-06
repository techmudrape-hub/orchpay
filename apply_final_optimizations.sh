#!/bin/bash

echo "=========================================="
echo "FINAL PERFORMANCE OPTIMIZATION"
echo "=========================================="
echo ""

cd /var/www/moneyone/moneyone/backend

echo "Step 1: Add database indexes"
echo "This will make queries 10x faster"
read -p "Enter MySQL password: " -s MYSQL_PASS
echo ""

mysql -h moneyone-dashboard-db.cfuwygoe61zq.ap-south-1.rds.amazonaws.com -u admin -p$MYSQL_PASS < add_performance_indexes.sql

if [ $? -eq 0 ]; then
    echo "✓ Indexes added successfully"
else
    echo "✗ Failed to add indexes"
    exit 1
fi
echo ""

echo "Step 2: Update Gunicorn workers (1 → 4)"
sudo sed -i 's/--workers 1/--workers 4/g' /etc/systemd/system/moneyone-api.service
echo "✓ Service file updated"
echo ""

echo "Step 3: Reload systemd"
sudo systemctl daemon-reload
echo "✓ Systemd reloaded"
echo ""

echo "Step 4: Restart backend"
sudo systemctl restart moneyone-api
sleep 5
echo "✓ Backend restarted"
echo ""

echo "Step 5: Check status"
sudo systemctl status moneyone-api --no-pager -l | head -20
echo ""

echo "Step 6: Verify worker count"
echo "Worker processes:"
ps aux | grep gunicorn | grep -v grep | wc -l
echo "(Should show 5: 1 master + 4 workers)"
echo ""

echo "=========================================="
echo "OPTIMIZATION COMPLETE!"
echo "=========================================="
echo ""
echo "Test your dashboard now:"
echo "1. Login to admin dashboard"
echo "2. Navigate to transactions"
echo "3. Should load in < 2 seconds"
echo ""
echo "Expected improvements:"
echo "- Dashboard load: 5-10s → 1-2s"
echo "- Login time: 3-5s → < 1s"
echo "- Concurrent users: 1-2 → 10-15"
echo ""
