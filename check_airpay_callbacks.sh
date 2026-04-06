#!/bin/bash

echo "======================================================================================================"
echo "AIRPAY CALLBACK CHECKER"
echo "======================================================================================================"
echo ""
echo "Checking callbacks received at: https://api.orchpay.in/api/callback/airpay/payin"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check 1: Callback log files
echo "======================================================================================================"
echo "1. CALLBACK LOG FILES"
echo "======================================================================================================"
echo ""

LOG_DIR="/var/www/moneyone/moneyone/backend/logs"

if [ -d "$LOG_DIR" ]; then
    echo "📁 Log directory: $LOG_DIR"
    echo ""
    
    # Find Airpay callback log files
    CALLBACK_LOGS=$(find "$LOG_DIR" -name "airpay_callbacks_*.log" 2>/dev/null)
    
    if [ -z "$CALLBACK_LOGS" ]; then
        echo "⚠️  No Airpay callback log files found"
        echo "   This means no callbacks have been received yet."
    else
        echo "✅ Found Airpay callback log files:"
        ls -lh "$LOG_DIR"/airpay_callbacks_*.log 2>/dev/null
        
        echo ""
        echo "📖 Most recent callback log entries (last 50 lines):"
        echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
        
        # Get the most recent log file
        LATEST_LOG=$(ls -t "$LOG_DIR"/airpay_callbacks_*.log 2>/dev/null | head -1)
        
        if [ -f "$LATEST_LOG" ]; then
            tail -50 "$LATEST_LOG"
        fi
    fi
else
    echo "❌ Log directory not found: $LOG_DIR"
fi

# Check 2: Systemd journal logs
echo ""
echo "======================================================================================================"
echo "2. SYSTEMD JOURNAL LOGS (Last 2 hours)"
echo "======================================================================================================"
echo ""

echo "🔍 Searching for Airpay callback entries..."
echo ""

# Search for Airpay-related logs
AIRPAY_LOGS=$(sudo journalctl -u moneyone-backend --since '2 hours ago' --no-pager 2>/dev/null | grep -i "airpay.*callback" | tail -20)

if [ -z "$AIRPAY_LOGS" ]; then
    echo "⚠️  No Airpay callback entries found in systemd logs (last 2 hours)"
else
    echo "✅ Found Airpay callback entries:"
    echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
    echo "$AIRPAY_LOGS"
fi

# Check 3: Recent Airpay transactions
echo ""
echo "======================================================================================================"
echo "3. RECENT AIRPAY TRANSACTIONS"
echo "======================================================================================================"
echo ""

cd /var/www/moneyone/moneyone/backend || exit 1

if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    
    echo "📊 Checking database for recent Airpay transactions..."
    echo ""
    
    python3 check_airpay_simple.py 2>/dev/null || echo "❌ Error running check script"
else
    echo "❌ Virtual environment not found"
fi

# Check 4: Callback endpoint accessibility
echo ""
echo "======================================================================================================"
echo "4. CALLBACK ENDPOINT STATUS"
echo "======================================================================================================"
echo ""

CALLBACK_URL="https://api.orchpay.in/api/callback/airpay/payin"

echo "🌐 Testing callback endpoint: $CALLBACK_URL"
echo ""

# Try to access the endpoint
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$CALLBACK_URL" 2>/dev/null)

if [ "$HTTP_CODE" = "405" ] || [ "$HTTP_CODE" = "400" ]; then
    echo "✅ Endpoint is accessible (HTTP $HTTP_CODE)"
    echo "   ✓ Endpoint correctly rejects GET requests (expects POST)"
elif [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Endpoint is accessible (HTTP $HTTP_CODE)"
else
    echo "⚠️  Endpoint returned HTTP $HTTP_CODE"
fi

# Summary
echo ""
echo "======================================================================================================"
echo "SUMMARY & NEXT STEPS"
echo "======================================================================================================"
echo ""
echo "📋 What was checked:"
echo "  1. Callback log files in $LOG_DIR"
echo "  2. Systemd journal logs (last 2 hours)"
echo "  3. Database transactions (payin_transactions table)"
echo "  4. Callback endpoint accessibility"
echo ""
echo "🔍 How to interpret results:"
echo "  - If log files exist with entries → Callbacks were received"
echo "  - If transactions show 'updated' → Callback was processed"
echo "  - If no logs/updates → No callbacks received yet from Airpay"
echo ""
echo "💡 If no callbacks received:"
echo "  1. Make a test payment using the QR code"
echo "  2. Wait 60 seconds for auto status check"
echo "  3. Run this script again to check for updates"
echo "  4. Contact Airpay support if still no callbacks"
echo ""
echo "📞 Airpay Support:"
echo "  - Email: support@airpay.co.in"
echo "  - Merchant ID: 354479"
echo "  - Callback URL: $CALLBACK_URL"
echo ""
echo "======================================================================================================"
