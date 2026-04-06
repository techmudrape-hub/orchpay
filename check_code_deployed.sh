#!/bin/bash

echo "=========================================="
echo "Checking if PayIn Unsettled Fix is Deployed"
echo "=========================================="

echo ""
echo "1. Checking if backend files have the fix..."

# Check if payin_routes.py has credit_admin_unsettled_wallet
if grep -q "credit_admin_unsettled_wallet" backend/payin_routes.py; then
    echo "✓ payin_routes.py has credit_admin_unsettled_wallet"
else
    echo "❌ payin_routes.py does NOT have credit_admin_unsettled_wallet"
fi

# Check if mudrape_routes.py has credit_unsettled_wallet
if grep -q "credit_unsettled_wallet" backend/mudrape_routes.py; then
    echo "✓ mudrape_routes.py has credit_unsettled_wallet"
else
    echo "❌ mudrape_routes.py does NOT have credit_unsettled_wallet"
fi

# Check if tourquest_routes.py has credit_unsettled_wallet
if grep -q "credit_unsettled_wallet" backend/tourquest_routes.py; then
    echo "✓ tourquest_routes.py has credit_unsettled_wallet"
else
    echo "❌ tourquest_routes.py does NOT have credit_unsettled_wallet"
fi

echo ""
echo "2. Checking backend service status..."
sudo systemctl status moneyone-backend --no-pager | head -20

echo ""
echo "3. Checking recent backend logs for errors..."
sudo journalctl -u moneyone-backend -n 50 --no-pager | tail -20

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Run: cd backend && python3 check_latest_payin.py"
echo "2. This will show if your recent payin used the correct wallet system"
echo "3. If it shows 'OLD WALLET SYSTEM', run: ./deploy_payin_unsettled_fix.sh"
