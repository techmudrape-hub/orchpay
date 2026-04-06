#!/bin/bash

echo "========================================="
echo "APPLYING LOAD OPTIMIZATION"
echo "========================================="
echo ""

# Install gevent
echo "Step 1: Installing gevent..."
cd /home/ubuntu/moneyone-backend
source venv/bin/activate
pip install gevent
echo "✓ Gevent installed"
echo ""

# Backup current Gunicorn config
echo "Step 2: Backing up Gunicorn config..."
sudo cp /etc/systemd/system/gunicorn.service /etc/systemd/system/gunicorn.service.backup
echo "✓ Backup created"
echo ""

# Update Gunicorn service with gevent
echo "Step 3: Updating Gunicorn to use gevent..."
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=Gunicorn instance to serve MoneyOne Backend
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/moneyone-backend/backend
Environment="PATH=/home/ubuntu/moneyone-backend/venv/bin"
ExecStart=/home/ubuntu/moneyone-backend/venv/bin/gunicorn \\
    --workers 2 \\
    --worker-class gevent \\
    --worker-connections 1000 \\
    --timeout 120 \\
    --backlog 2048 \\
    --max-requests 1000 \\
    --max-requests-jitter 50 \\
    --bind 0.0.0.0:5000 \\
    --access-logfile /var/log/gunicorn/access.log \\
    --error-logfile /var/log/gunicorn/error.log \\
    --log-level info \\
    app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
echo "✓ Gunicorn config updated"
echo ""

# Reload and restart
echo "Step 4: Restarting Gunicorn..."
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
sleep 3
echo "✓ Gunicorn restarted"
echo ""

# Check status
echo "Step 5: Checking status..."
sudo systemctl status gunicorn --no-pager | head -15
echo ""

# Test health endpoint
echo "Step 6: Testing health endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Health check passed (HTTP $HTTP_CODE)"
else
    echo "✗ Health check failed (HTTP $HTTP_CODE)"
fi
echo ""

# Show worker info
echo "Step 7: Worker information..."
ps aux | grep gunicorn | grep -v grep
echo ""

echo "========================================="
echo "OPTIMIZATION COMPLETE"
echo "========================================="
echo ""
echo "Changes applied:"
echo "- Workers: 4 sync → 2 gevent"
echo "- Connections per worker: 1 → 1000"
echo "- Total capacity: 4 → 2000 concurrent requests"
echo "- Timeout: 30s → 120s"
echo "- Request queue: 2048"
echo "- Auto-restart after 1000 requests"
echo ""
echo "Expected improvement: 10-50x more capacity"
echo ""
echo "Monitor with:"
echo "  sudo journalctl -u gunicorn -f"
echo ""
echo "Test load with:"
echo "  ab -n 1000 -c 100 http://localhost:5000/health"
