#!/bin/bash

echo "=========================================="
echo "Checking Backend Instances"
echo "=========================================="

# Check if multiple backend processes are running
echo ""
echo "1. Checking running Python processes:"
echo "--------------------------------------"
ps aux | grep -E "app.py|gunicorn|uwsgi" | grep -v grep

echo ""
echo "2. Checking systemd services:"
echo "--------------------------------------"
sudo systemctl list-units | grep -i moneyone

echo ""
echo "3. Checking listening ports:"
echo "--------------------------------------"
sudo netstat -tlnp | grep -E ":5000|:8000|:3000"

echo ""
echo "4. Checking if load balancer is configured:"
echo "--------------------------------------"
if [ -f "/etc/nginx/sites-enabled/moneyone" ]; then
    echo "✅ Nginx config found"
    grep -E "upstream|proxy_pass" /etc/nginx/sites-enabled/moneyone 2>/dev/null || echo "No upstream config"
else
    echo "No Nginx config found"
fi

echo ""
echo "5. Checking AWS Load Balancer (if applicable):"
echo "--------------------------------------"
curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null && echo "Running on AWS EC2" || echo "Not on AWS or metadata unavailable"

echo ""
echo "6. Running diagnosis script:"
echo "--------------------------------------"
cd /home/ubuntu/moneyone_backend/backend
python3 diagnose_balance_issue.py 9000000001

echo ""
echo "=========================================="
echo "Check Complete"
echo "=========================================="
