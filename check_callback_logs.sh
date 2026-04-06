#!/bin/bash

echo "=========================================="
echo "Checking Callback Logs"
echo "=========================================="

echo ""
echo "1. Checking if ANY callbacks were received today..."
sudo journalctl -u moneyone-api --since today | grep -i "callback received" | tail -20

echo ""
echo "=========================================="
echo "2. Checking for callback errors..."
sudo journalctl -u moneyone-api --since today | grep -i "callback.*error" | tail -20

echo ""
echo "=========================================="
echo "3. Checking for successful callback processing..."
sudo journalctl -u moneyone-api --since today | grep -i "callback processed successfully" | tail -20

echo ""
echo "=========================================="
echo "4. Checking last 50 lines for any callback activity..."
sudo journalctl -u moneyone-api -n 50 | grep -i callback

echo ""
echo "=========================================="
echo "5. Checking if callback routes are registered..."
sudo journalctl -u moneyone-api --since "10 minutes ago" | grep -i "blueprint\|route" | grep -i callback

echo ""
echo "=========================================="
echo "Summary:"
echo "=========================================="
echo "If you see 'Callback Received' messages above, callbacks ARE working."
echo "If you see NO messages, callbacks are NOT being sent by Mudrape."
echo ""
echo "Next steps:"
echo "1. Verify callback URL with Mudrape support"
echo "2. Test callback endpoint: bash test_callback_endpoint.sh"
echo "3. Check Nginx logs: sudo tail -f /var/log/nginx/access.log | grep callback"
echo "=========================================="
