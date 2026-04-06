#!/bin/bash

# Check Mudrape Callback Status
# Quick script to verify if Mudrape is sending callbacks

echo "========================================="
echo "MUDRAPE CALLBACK STATUS CHECK"
echo "========================================="
echo ""

# Navigate to backend directory
cd /var/www/moneyone/moneyone/backend || exit 1

# Activate virtual environment
source /var/www/moneyone/venv/bin/activate

# Run the check
python3 check_mudrape_callback_received.py "$@"

echo ""
echo "========================================="
echo "ADDITIONAL CHECKS"
echo "========================================="
echo ""

# Check recent backend logs for callback entries
echo "Recent Mudrape callback log entries (last 10):"
echo "---------------------------------------------"
if [ -f /var/www/moneyone/logs/backend.log ]; then
    grep "Mudrape Payout Callback Received" /var/www/moneyone/logs/backend.log | tail -10
    
    if [ $? -ne 0 ]; then
        echo "❌ No callback log entries found in backend.log"
        echo ""
        echo "This means either:"
        echo "  1. Mudrape is not sending callbacks to your server"
        echo "  2. Callbacks are being blocked by firewall/security groups"
        echo "  3. Callback URL is not configured in Mudrape dashboard"
    fi
else
    echo "❌ Backend log file not found at /var/www/moneyone/logs/backend.log"
fi

echo ""
echo "To monitor callbacks in real-time, run:"
echo "  tail -f /var/www/moneyone/logs/backend.log | grep -A 20 'Mudrape Payout Callback'"
echo ""
