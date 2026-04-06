#!/bin/bash

echo "=========================================="
echo "Checking Backend Error Logs"
echo "=========================================="
echo ""

ssh ubuntu@13.127.135.229 << 'EOF'
echo "=== Last 50 lines of backend logs ==="
sudo journalctl -u moneyone-backend -n 50 --no-pager

echo ""
echo "=== Searching for 'format string' errors ==="
sudo journalctl -u moneyone-backend -n 200 --no-pager | grep -i "format string" -A 5 -B 5

echo ""
echo "=== Searching for 'fetch-fund' errors ==="
sudo journalctl -u moneyone-backend -n 200 --no-pager | grep -i "fetch-fund" -A 5 -B 5

echo ""
echo "=== Searching for 'wallet/merchant/overview' errors ==="
sudo journalctl -u moneyone-backend -n 200 --no-pager | grep -i "wallet/merchant/overview" -A 5 -B 5
EOF
