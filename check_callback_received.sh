#!/bin/bash

# Script to check if a specific Mudrape callback was received
# Based on the callback payload structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"

echo "=========================================="
echo "Mudrape Callback Verification"
echo "=========================================="
echo ""

# Function to show usage
show_usage() {
    echo "Usage:"
    echo ""
    echo "  Check by ref_id (order_id):"
    echo "    ./check_callback_received.sh --ref-id <order_id>"
    echo ""
    echo "  Check by PG transaction ID:"
    echo "    ./check_callback_received.sh --txn-id <mudrape_txn_id>"
    echo ""
    echo "  Check by ref_id and verify PG TXN ID:"
    echo "    ./check_callback_received.sh --ref-id <order_id> --txn-id <mudrape_txn_id>"
    echo ""
    echo "  Check with all details (recommended):"
    echo "    ./check_callback_received.sh --ref-id <order_id> --txn-id <mudrape_txn_id> --amount <amount>"
    echo ""
    echo "Examples:"
    echo "  ./check_callback_received.sh --ref-id 20260303133259143440"
    echo "  ./check_callback_received.sh --ref-id 20260303133259143440 --txn-id MPAY80087485652"
    echo "  ./check_callback_received.sh --ref-id 20260303133259143440 --txn-id MPAY80087485652 --amount 300"
    echo ""
    echo "Expected callback format:"
    echo '  {'
    echo '    "amount": 300,'
    echo '    "ref_id": "20260303133259143440",'
    echo '    "source": "SUCCESS",'
    echo '    "status": "SUCCESS",'
    echo '    "txn_id": "MPAY80087485652",'
    echo '    "payeeVpa": "9810244341.2@hdfc",'
    echo '    "timestamp": "2026-03-03T08:03:35.668Z"'
    echo '  }'
    echo ""
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Navigate to backend directory
cd "$BACKEND_DIR" || {
    echo "ERROR: Cannot navigate to backend directory: $BACKEND_DIR"
    exit 1
}

# Run the Python script with all arguments
python3 check_specific_callback.py "$@"

exit_code=$?

echo ""
echo "=========================================="
if [ $exit_code -eq 0 ]; then
    echo "✓ Verification completed"
else
    echo "✗ Verification failed with exit code: $exit_code"
fi
echo "=========================================="

exit $exit_code
