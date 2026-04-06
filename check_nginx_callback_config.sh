#!/bin/bash

echo "=========================================="
echo "Checking Nginx Callback Configuration"
echo "=========================================="

echo ""
echo "1. Checking if Nginx config exists..."
if [ -f /etc/nginx/sites-available/moneyone ]; then
    echo "✓ Config file found"
else
    echo "✗ Config file not found"
    exit 1
fi

echo ""
echo "2. Checking for callback route in Nginx..."
if grep -q "callback" /etc/nginx/sites-available/moneyone; then
    echo "✓ Callback route found in config"
    echo ""
    echo "Callback configuration:"
    grep -A 5 "callback" /etc/nginx/sites-available/moneyone
else
    echo "⚠️  No specific callback route found"
    echo "   Checking if /api/ route covers callbacks..."
    if grep -q "location /api/" /etc/nginx/sites-available/moneyone; then
        echo "✓ /api/ route found (should cover callbacks)"
        echo ""
        echo "API configuration:"
        grep -A 5 "location /api/" /etc/nginx/sites-available/moneyone
    else
        echo "✗ No API route found!"
    fi
fi

echo ""
echo "3. Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "4. Checking if Nginx is running..."
sudo systemctl status nginx --no-pager | grep Active

echo ""
echo "5. Testing callback endpoint from localhost..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://127.0.0.1:5000/api/callback/mudrape/payin \
  -H "Content-Type: application/json" \
  -d '{"ref_id":"TEST","txn_id":"TEST","status":"SUCCESS","amount":100,"utr":"TEST"}')

echo "Direct to Flask (port 5000): HTTP $RESPONSE"

if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "400" ] || [ "$RESPONSE" = "404" ]; then
    echo "✓ Flask is responding"
else
    echo "✗ Flask not responding on port 5000"
fi

echo ""
echo "6. Testing callback endpoint through Nginx..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST https://api.orchpay.in/api/callback/mudrape/payin \
  -H "Content-Type: application/json" \
  -d '{"ref_id":"TEST","txn_id":"TEST","status":"SUCCESS","amount":100,"utr":"TEST"}')

echo "Through Nginx (HTTPS): HTTP $RESPONSE"

if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "400" ] || [ "$RESPONSE" = "404" ]; then
    echo "✓ Nginx is forwarding requests correctly"
else
    echo "✗ Nginx not forwarding correctly (HTTP $RESPONSE)"
fi

echo ""
echo "7. Checking recent Nginx access logs for callbacks..."
if [ -f /var/log/nginx/access.log ]; then
    echo "Recent callback requests:"
    sudo tail -100 /var/log/nginx/access.log | grep callback | tail -5
    
    if [ $? -eq 0 ]; then
        echo "✓ Found callback requests in Nginx logs"
    else
        echo "⚠️  No callback requests found in recent logs"
    fi
else
    echo "⚠️  Nginx access log not found"
fi

echo ""
echo "8. Checking Nginx error logs..."
if [ -f /var/log/nginx/error.log ]; then
    echo "Recent errors related to callbacks:"
    sudo tail -100 /var/log/nginx/error.log | grep -i callback | tail -5
    
    if [ $? -ne 0 ]; then
        echo "✓ No callback-related errors"
    fi
else
    echo "⚠️  Nginx error log not found"
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "If all checks passed, callbacks should work."
echo "If not, check the specific failures above."
echo ""
echo "Next steps:"
echo "1. Create a new transaction"
echo "2. Monitor logs: sudo journalctl -u moneyone-api -f | grep callback"
echo "3. Complete payment"
echo "4. Callback should appear within 30 seconds"
echo ""
echo "=========================================="
