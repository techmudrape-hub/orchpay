#!/bin/bash

echo "=========================================="
echo "ViyonaPay Setup Verification"
echo "=========================================="
echo ""

echo "Step 1: Checking if callback route is registered in app.py..."
echo "=========================================="
cd backend
grep -n "viyonapay" app.py -i || echo "⚠️  No viyonapay routes found in app.py"

echo ""
echo ""
echo "Step 2: Checking application logs for ViyonaPay..."
echo "=========================================="

# Check common log locations
LOG_LOCATIONS=(
    "/var/log/moneyone/backend.log"
    "/var/log/moneyone/app.log"
    "/var/www/moneyone/moneyone/backend/app.log"
    "/var/www/moneyone/moneyone/logs/backend.log"
    "app.log"
    "backend.log"
)

for log in "${LOG_LOCATIONS[@]}"; do
    if [ -f "$log" ]; then
        echo "Found log: $log"
        echo "Last 50 lines with 'viyona':"
        tail -200 "$log" | grep -i viyona | tail -50
        echo ""
    fi
done

echo ""
echo "Step 3: Checking if Flask/Gunicorn is running..."
echo "=========================================="
ps aux | grep -E "(gunicorn|flask|python.*app\.py)" | grep -v grep

echo ""
echo ""
echo "Step 4: Checking systemd service logs (if applicable)..."
echo "=========================================="
if command -v journalctl &> /dev/null; then
    journalctl -u moneyone-backend --since "1 hour ago" --no-pager | grep -i viyona | tail -50 || echo "No systemd logs found"
else
    echo "journalctl not available"
fi

echo ""
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Check if ViyonaPay callback URL is registered with them:"
echo "   https://your-domain.com/api/callback/viyonapay/payin"
echo ""
echo "2. Test the callback endpoint manually:"
echo "   curl -X POST https://your-domain.com/api/callback/viyonapay/payin \\"
echo "        -H 'Content-Type: application/json' \\"
echo "        -d '{\"test\": \"data\"}'"
echo ""
echo "3. Check nginx/apache access logs for POST requests:"
echo "   tail -f /var/log/nginx/access.log | grep viyonapay"
echo ""
echo "4. Contact ViyonaPay support to verify:"
echo "   - Callback URL is registered"
echo "   - They're sending callbacks"
echo "   - Get a sample callback payload"
echo ""
