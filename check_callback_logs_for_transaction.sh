#!/bin/bash

# Check Backend Logs for Specific Transaction Callback
# Shows what happened when the callback was received

if [ -z "$1" ]; then
    echo "Usage: ./check_callback_logs_for_transaction.sh <reference_id>"
    echo "Example: ./check_callback_logs_for_transaction.sh DP20260309194553D659F8"
    exit 1
fi

REFERENCE_ID=$1

echo "========================================="
echo "CHECKING CALLBACK LOGS FOR: $REFERENCE_ID"
echo "========================================="
echo ""

LOG_FILE="/var/www/moneyone/logs/backend.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Log file not found: $LOG_FILE"
    exit 1
fi

echo "Searching for callback entries..."
echo "---------------------------------------------"
echo ""

# Search for the reference ID in logs
grep -A 50 "$REFERENCE_ID" "$LOG_FILE" | grep -A 50 "Mudrape Payout Callback" | head -100

echo ""
echo "========================================="
echo "CHECKING FOR WALLET DEDUCTION"
echo "========================================="
echo ""

# Check if wallet was debited
grep "$REFERENCE_ID" "$LOG_FILE" | grep -i "wallet"

echo ""
echo "========================================="
echo "CHECKING FOR ERRORS"
echo "========================================="
echo ""

# Check for errors related to this transaction
grep "$REFERENCE_ID" "$LOG_FILE" | grep -i "error\|failed\|exception"

echo ""
echo "Done!"
