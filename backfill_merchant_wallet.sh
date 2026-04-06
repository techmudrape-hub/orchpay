#!/bin/bash

# Quick script to backfill merchant payout wallet deductions
# Usage: ./backfill_merchant_wallet.sh <merchant_id> [--live]

if [ -z "$1" ]; then
    echo "Usage: ./backfill_merchant_wallet.sh <merchant_id> [--live]"
    echo ""
    echo "Examples:"
    echo "  ./backfill_merchant_wallet.sh 9000000001          # Dry run (preview only)"
    echo "  ./backfill_merchant_wallet.sh 9000000001 --live   # Apply changes"
    echo ""
    exit 1
fi

MERCHANT_ID=$1
MODE=$2

echo "=========================================="
echo "Backfill Merchant Payout Wallet"
echo "=========================================="
echo "Merchant ID: $MERCHANT_ID"
echo ""

# Check if running on server or local
if [ -f "/home/ubuntu/moneyone_backend/backfill_merchant_payout_wallet.py" ]; then
    # Running on server
    cd /home/ubuntu/moneyone_backend
    python3 backfill_merchant_payout_wallet.py $MERCHANT_ID $MODE
else
    # Running locally - need to SSH to server
    echo "This script must be run on the server."
    echo ""
    echo "To run on server:"
    echo "  1. SSH to server: ssh -i ~/.ssh/moneyone-new-ec2.pem ubuntu@<IP>"
    echo "  2. Navigate to backend: cd /home/ubuntu/moneyone_backend"
    echo "  3. Run script: python3 backfill_merchant_payout_wallet.py $MERCHANT_ID $MODE"
    echo ""
    exit 1
fi
