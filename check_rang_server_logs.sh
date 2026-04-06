#!/bin/bash

echo "CHECKING SERVER LOGS FOR RANG CALLBACKS"
echo "========================================"

echo ""
echo "1. Checking Nginx access logs for Rang callback attempts..."
echo "-----------------------------------------------------------"
sudo grep -i "rang.*callback\|POST.*rang" /var/log/nginx/access.log | tail -10

echo ""
echo "2. Checking for any POST requests to callback endpoints today..."
echo "---------------------------------------------------------------"
sudo grep "$(date +%d/%b/%Y)" /var/log/nginx/access.log | grep "POST.*callback" | tail -10

echo ""
echo "3. Checking application logs for Rang-related entries..."
echo "--------------------------------------------------------"
sudo journalctl -u moneyone-backend --since today | grep -i rang | tail -10

echo ""
echo "4. Checking for any callback-related errors..."
echo "----------------------------------------------"
sudo journalctl -u moneyone-backend --since today | grep -i "callback\|error" | tail -10

echo ""
echo "5. Real-time monitoring (press Ctrl+C to stop)..."
echo "-------------------------------------------------"
echo "Monitoring for Rang callbacks..."
sudo tail -f /var/log/nginx/access.log | grep --line-buffered -i "rang\|callback"