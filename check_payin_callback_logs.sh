#!/bin/bash

echo "=========================================="
echo "CHECKING PAYIN CALLBACK LOGS"
echo "=========================================="

echo ""
echo "Last 50 lines of backend logs (filtered for payin callback):"
echo "----------------------------------------------"
sudo journalctl -u moneyone-api -n 100 --no-pager | grep -i "payin\|callback\|unsettled\|wallet"

echo ""
echo "=========================================="
echo "CHECKING RECENT PAYIN TRANSACTION"
echo "=========================================="
cd /var/www/moneyone/moneyone/backend
python3 check_recent_payin.py
