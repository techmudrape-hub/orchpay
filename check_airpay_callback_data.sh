#!/bin/bash
# Quick script to check Airpay callback data

echo "=========================================="
echo "AIRPAY CALLBACK DATA CHECKER"
echo "=========================================="

cd /var/www/moneyone/moneyone/backend

echo ""
echo "1. Checking recent Airpay transactions..."
echo "------------------------------------------"
source venv/bin/activate
python3 check_recent_airpay_transactions.py

echo ""
echo ""
echo "2. Checking callback log files..."
echo "------------------------------------------"
if [ -d "logs" ]; then
    echo "Recent callback logs:"
    ls -lh logs/airpay_callbacks_*.log 2>/dev/null || echo "No callback log files found"
    echo ""
    echo "Last 50 lines from most recent log:"
    tail -50 logs/airpay_callbacks_*.log 2>/dev/null | tail -50 || echo "No callback logs available"
else
    echo "Logs directory does not exist"
fi

echo ""
echo ""
echo "3. Checking server logs for Airpay callbacks..."
echo "------------------------------------------"
echo "Last 20 Airpay callback entries:"
sudo journalctl -u moneyone-backend --since '24 hours ago' | grep -i 'airpay.*callback' | tail -20

echo ""
echo ""
echo "=========================================="
echo "DONE"
echo "=========================================="
