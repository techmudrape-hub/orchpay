#!/bin/bash

echo "=========================================="
echo "MUDRAPE CALLBACK LOG CHECKER"
echo "=========================================="
echo ""

# Check if running on server
if [ ! -f "/var/log/gunicorn/error.log" ]; then
    echo "⚠ Not on production server or logs not in standard location"
    echo "Checking local logs..."
    LOG_FILE="backend/logs/app.log"
else
    LOG_FILE="/var/log/gunicorn/error.log"
fi

echo "Checking log file: $LOG_FILE"
echo ""

# 1. Check for Mudrape callback requests
echo "1. Recent Mudrape Payin Callback Requests:"
echo "-------------------------------------------"
if [ -f "$LOG_FILE" ]; then
    grep -i "Mudrape Payin Callback Received" "$LOG_FILE" | tail -20
    
    if [ $? -ne 0 ]; then
        echo "❌ No Mudrape payin callback requests found in logs"
        echo "   This means Mudrape is NOT sending callbacks to your server"
    fi
else
    echo "❌ Log file not found: $LOG_FILE"
fi
echo ""

# 2. Check for callback forwarding attempts
echo "2. Merchant Callback Forwarding Attempts:"
echo "-------------------------------------------"
if [ -f "$LOG_FILE" ]; then
    grep -i "Forwarding callback to merchant" "$LOG_FILE" | tail -10
    
    if [ $? -ne 0 ]; then
        echo "⚠ No merchant callback forwarding attempts found"
        echo "   Callbacks may not be reaching the forwarding logic"
    fi
else
    echo "❌ Log file not found"
fi
echo ""

# 3. Check for callback errors
echo "3. Callback Errors:"
echo "-------------------------------------------"
if [ -f "$LOG_FILE" ]; then
    grep -i "ERROR.*callback" "$LOG_FILE" | tail -10
    
    if [ $? -ne 0 ]; then
        echo "✓ No callback errors found"
    fi
else
    echo "❌ Log file not found"
fi
echo ""

# 4. Check nginx access logs for callback endpoint
echo "4. Nginx Access Logs (Callback Endpoint):"
echo "-------------------------------------------"
if [ -f "/var/log/nginx/access.log" ]; then
    grep "/api/callback/mudrape/payin" /var/log/nginx/access.log | tail -10
    
    if [ $? -ne 0 ]; then
        echo "❌ No requests to /api/callback/mudrape/payin found in nginx logs"
        echo "   Mudrape is NOT hitting your callback endpoint"
    fi
else
    echo "⚠ Nginx access log not found (may not be on production server)"
fi
echo ""

# 5. Check if callback endpoint is accessible
echo "5. Testing Callback Endpoint Accessibility:"
echo "-------------------------------------------"
echo "Testing POST to http://localhost:5000/api/callback/mudrape/payin"
curl -X POST http://localhost:5000/api/callback/mudrape/payin \
    -H "Content-Type: application/json" \
    -d '{"ref_id":"TEST123","status":"SUCCESS"}' \
    -w "\nHTTP Status: %{http_code}\n" \
    2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ Cannot reach callback endpoint (backend may not be running)"
fi
echo ""

echo "=========================================="
echo "RECOMMENDATIONS"
echo "=========================================="
echo ""
echo "If no callbacks are being received:"
echo "  1. Verify Mudrape callback URL configuration in their dashboard"
echo "  2. Ensure your server's callback URL is publicly accessible"
echo "  3. Check firewall rules allow incoming POST requests"
echo "  4. Verify nginx is properly proxying to backend"
echo ""
echo "If callbacks are received but not forwarded:"
echo "  1. Run: python3 backend/diagnose_mudrape_callback.py"
echo "  2. Check if callback_url is stored in transactions"
echo "  3. Verify merchant_callbacks table has URLs configured"
echo ""
