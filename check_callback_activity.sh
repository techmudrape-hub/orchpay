#!/bin/bash

echo "=========================================="
echo "CHECKING CALLBACK ACTIVITY"
echo "=========================================="
echo ""

LOG_FILE="/var/log/gunicorn/error.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "⚠ Log file not found: $LOG_FILE"
    echo "Trying alternative location..."
    LOG_FILE="/var/log/gunicorn/gunicorn.log"
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Cannot find gunicorn logs"
    exit 1
fi

echo "Using log file: $LOG_FILE"
echo ""

# Check for recent Mudrape callbacks
echo "1. Recent Mudrape Payin Callbacks (last 50 lines):"
echo "---------------------------------------------------"
grep -i "Mudrape Payin Callback Received" "$LOG_FILE" | tail -50

if [ $? -ne 0 ]; then
    echo "❌ NO Mudrape payin callbacks found in logs!"
    echo ""
    echo "This means Mudrape is NOT sending callbacks to your server."
    echo ""
    echo "Possible reasons:"
    echo "  1. Mudrape callback URL not configured in their dashboard"
    echo "  2. Your callback endpoint is not publicly accessible"
    echo "  3. Firewall blocking incoming requests"
    echo ""
else
    echo ""
    echo "✓ Mudrape IS sending callbacks"
fi

echo ""
echo "2. Callback Forwarding to Merchant:"
echo "---------------------------------------------------"
grep -i "Forwarding callback to merchant" "$LOG_FILE" | tail -20

if [ $? -ne 0 ]; then
    echo "⚠ No merchant callback forwarding found"
else
    echo ""
    echo "✓ Callbacks are being forwarded"
fi

echo ""
echo "3. Recent Callback Errors:"
echo "---------------------------------------------------"
grep -i "ERROR.*callback" "$LOG_FILE" | tail -10

if [ $? -ne 0 ]; then
    echo "✓ No callback errors"
fi

echo ""
echo "4. Last 20 lines of log (for context):"
echo "---------------------------------------------------"
tail -20 "$LOG_FILE"

echo ""
echo "=========================================="
echo "RECOMMENDATIONS"
echo "=========================================="
echo ""
echo "To monitor callbacks in real-time:"
echo "  tail -f $LOG_FILE | grep -i callback"
echo ""
echo "To test callback endpoint manually:"
echo "  curl -X POST http://localhost:5000/api/callback/mudrape/payin \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"ref_id\":\"TEST123\",\"status\":\"SUCCESS\",\"utr\":\"123456789\"}'"
echo ""
