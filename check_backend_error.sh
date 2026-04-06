#!/bin/bash

echo "=========================================="
echo "CHECKING BACKEND ERROR"
echo "=========================================="
echo ""

echo "Step 1: Check service status"
sudo systemctl status moneyone-api --no-pager -l
echo ""

echo "Step 2: Check recent error logs"
sudo journalctl -u moneyone-api -n 50 --no-pager
echo ""

echo "Step 3: Check if database_pooled.py exists"
ls -la /var/www/moneyone/moneyone/backend/database_pooled.py
echo ""

echo "Step 4: Test Python import"
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 -c "from database_pooled import get_db_connection, init_database; print('Import successful')" 2>&1
echo ""

echo "Step 5: Check for syntax errors in database_pooled.py"
python3 -m py_compile database_pooled.py 2>&1
echo ""
