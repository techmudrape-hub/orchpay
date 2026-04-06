#!/bin/bash

echo "=============================================================================="
echo "PayTouch Callback Server Logs Analysis - $(date)"
echo "=============================================================================="

# Check if we're running on the server
if [ ! -f "/var/log/nginx/access.log" ] && [ ! -f "/var/log/apache2/access.log" ]; then
    echo "⚠️  Server log files not found. This script should be run on the server."
    echo "Common log locations:"
    echo "  - /var/log/nginx/access.log"
    echo "  - /var/log/apache2/access.log"
    echo "  - /var/log/httpd/access_log"
    echo ""
fi

echo "🔍 Searching for PayTouch callback requests in server logs..."
echo "------------------------------------------------------------------------------"

# Check Nginx logs
if [ -f "/var/log/nginx/access.log" ]; then
    echo "📋 Checking Nginx access logs..."
    
    # Look for PayTouch callback requests today
    echo "PayTouch callback requests today:"
    grep "$(date +%d/%b/%Y)" /var/log/nginx/access.log | grep "/api/callback/paytouch" | head -20
    
    echo ""
    echo "PayTouch callback request count today:"
    grep "$(date +%d/%b/%Y)" /var/log/nginx/access.log | grep "/api/callback/paytouch" | wc -l
    
    echo ""
    echo "Recent PayTouch callback requests (last 50):"
    grep "/api/callback/paytouch" /var/log/nginx/access.log | tail -50
    
    echo ""
    echo "PayTouch callback response codes:"
    grep "/api/callback/paytouch" /var/log/nginx/access.log | awk '{print $9}' | sort | uniq -c
fi

# Check Apache logs
if [ -f "/var/log/apache2/access.log" ]; then
    echo "📋 Checking Apache access logs..."
    
    # Look for PayTouch callback requests today
    echo "PayTouch callback requests today:"
    grep "$(date +%d/%b/%Y)" /var/log/apache2/access.log | grep "/api/callback/paytouch" | head -20
    
    echo ""
    echo "PayTouch callback request count today:"
    grep "$(date +%d/%b/%Y)" /var/log/apache2/access.log | grep "/api/callback/paytouch" | wc -l
    
    echo ""
    echo "Recent PayTouch callback requests (last 50):"
    grep "/api/callback/paytouch" /var/log/apache2/access.log | tail -50
fi

# Check application logs
echo ""
echo "🔍 Checking application logs for PayTouch callback processing..."
echo "------------------------------------------------------------------------------"

# Common application log locations
APP_LOG_LOCATIONS=(
    "/var/www/moneyone/moneyone/backend/app.log"
    "/var/log/moneyone/app.log"
    "/var/log/flask/app.log"
    "/tmp/moneyone.log"
    "backend/app.log"
)

for log_file in "${APP_LOG_LOCATIONS[@]}"; do
    if [ -f "$log_file" ]; then
        echo "📋 Checking $log_file..."
        
        # Look for PayTouch callback processing
        echo "PayTouch callback processing today:"
        grep "$(date +%Y-%m-%d)" "$log_file" | grep -i "paytouch.*callback" | head -20
        
        echo ""
        echo "PayTouch callback errors:"
        grep "$(date +%Y-%m-%d)" "$log_file" | grep -i "paytouch" | grep -i "error" | head -10
        
        echo ""
    fi
done

# Check Python application logs in current directory
if [ -f "nohup.out" ]; then
    echo "📋 Checking nohup.out for PayTouch callbacks..."
    grep -i "paytouch.*callback" nohup.out | tail -20
fi

# Check systemd journal if available
if command -v journalctl &> /dev/null; then
    echo ""
    echo "🔍 Checking systemd journal for PayTouch callbacks..."
    echo "------------------------------------------------------------------------------"
    
    # Check for PayTouch related entries today
    journalctl --since today | grep -i paytouch | head -20
fi

echo ""
echo "=============================================================================="
echo "SUMMARY & NEXT STEPS"
echo "=============================================================================="

echo "1. 🔍 Check the logs above for any PayTouch callback requests"
echo "2. 📊 If no callback requests found, PayTouch is not sending callbacks"
echo "3. 🔧 If callbacks are being received but not processed, check application logs"
echo "4. 📞 Contact PayTouch support to verify webhook configuration"
echo ""
echo "PayTouch Callback URL should be configured as:"
echo "https://api.orchpay.in/api/callback/paytouch/payout"
echo ""
echo "To run additional checks:"
echo "python3 backend/check_paytouch_callback_activity.py"
echo "python3 backend/test_paytouch_callback_endpoint.py"
echo ""
echo "=============================================================================="