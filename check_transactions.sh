#!/bin/bash
# MoneyOne Transaction Status Checker
# Usage: ./check_transactions.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        MoneyOne Transaction Status Report                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Database credentials (update these)
DB_USER="your_db_user"
DB_NAME="moneyone_db"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo -e "${RED}Error: psql command not found${NC}"
    exit 1
fi

# 1. PayIN Transactions Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. PAYIN TRANSACTIONS (Last 24 Hours)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    status,
    COUNT(*) as count,
    ROUND(SUM(amount)::numeric, 2) as total_amount,
    ROUND(AVG(amount)::numeric, 2) as avg_amount
FROM payin_transactions 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY status
ORDER BY count DESC;
" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Unable to query database${NC}"
fi
echo ""

# 2. PayOUT Transactions Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. PAYOUT TRANSACTIONS (Last 24 Hours)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    status,
    COUNT(*) as count,
    ROUND(SUM(amount)::numeric, 2) as total_amount,
    ROUND(AVG(amount)::numeric, 2) as avg_amount
FROM payout_transactions 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY status
ORDER BY count DESC;
" 2>/dev/null
echo ""

# 3. Pending Transactions Alert
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. PENDING TRANSACTIONS ALERT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PENDING_PAYIN=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'PENDING' AND created_at > NOW() - INTERVAL '24 hours';" 2>/dev/null | tr -d ' ')
PENDING_PAYOUT=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payout_transactions WHERE status IN ('INITIATED', 'QUEUED', 'INPROCESS') AND created_at > NOW() - INTERVAL '24 hours';" 2>/dev/null | tr -d ' ')

echo "PayIN Pending (24h): $PENDING_PAYIN"
if [ "$PENDING_PAYIN" -gt 50 ]; then
    echo -e "${YELLOW}⚠ Warning: High number of pending PayIN transactions${NC}"
fi

echo "PayOUT Pending (24h): $PENDING_PAYOUT"
if [ "$PENDING_PAYOUT" -gt 50 ]; then
    echo -e "${YELLOW}⚠ Warning: High number of pending PayOUT transactions${NC}"
fi
echo ""

# 4. Failed Transactions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. FAILED TRANSACTIONS (Last 1 Hour)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FAILED_PAYIN=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'FAILED' AND created_at > NOW() - INTERVAL '1 hour';" 2>/dev/null | tr -d ' ')
FAILED_PAYOUT=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payout_transactions WHERE status = 'FAILED' AND created_at > NOW() - INTERVAL '1 hour';" 2>/dev/null | tr -d ' ')

echo "PayIN Failed (1h): $FAILED_PAYIN"
echo "PayOUT Failed (1h): $FAILED_PAYOUT"

if [ "$FAILED_PAYIN" -gt 10 ] || [ "$FAILED_PAYOUT" -gt 10 ]; then
    echo -e "${RED}✗ ALERT: High failure rate detected!${NC}"
fi
echo ""

# 5. Recent Failed Transactions Details
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. RECENT FAILED PAYIN (Last 5)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    txn_id,
    amount,
    status,
    created_at,
    SUBSTRING(error_message, 1, 50) as error
FROM payin_transactions 
WHERE status = 'FAILED' 
ORDER BY created_at DESC 
LIMIT 5;
" 2>/dev/null
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. RECENT FAILED PAYOUT (Last 5)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    txn_id,
    amount,
    status,
    created_at,
    SUBSTRING(error_message, 1, 50) as error
FROM payout_transactions 
WHERE status = 'FAILED' 
ORDER BY created_at DESC 
LIMIT 5;
" 2>/dev/null
echo ""

# 6. Hourly Transaction Rate
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. HOURLY TRANSACTION RATE (Last 6 Hours)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    DATE_TRUNC('hour', created_at) as hour,
    COUNT(*) as payin_count,
    ROUND(SUM(amount)::numeric, 2) as payin_amount
FROM payin_transactions 
WHERE created_at > NOW() - INTERVAL '6 hours'
GROUP BY hour
ORDER BY hour DESC;
" 2>/dev/null
echo ""

# 7. Top Merchants by Transaction Volume
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. TOP MERCHANTS (Last 24 Hours)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    merchant_id,
    COUNT(*) as transaction_count,
    ROUND(SUM(amount)::numeric, 2) as total_amount
FROM payin_transactions 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY merchant_id
ORDER BY total_amount DESC
LIMIT 10;
" 2>/dev/null
echo ""

# 8. Success Rate
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9. SUCCESS RATE (Last 24 Hours)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_PAYIN=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payin_transactions WHERE created_at > NOW() - INTERVAL '24 hours';" 2>/dev/null | tr -d ' ')
SUCCESS_PAYIN=$(psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM payin_transactions WHERE status = 'SUCCESS' AND created_at > NOW() - INTERVAL '24 hours';" 2>/dev/null | tr -d ' ')

if [ "$TOTAL_PAYIN" -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; ($SUCCESS_PAYIN * 100) / $TOTAL_PAYIN" | bc)
    echo "PayIN Success Rate: ${SUCCESS_RATE}%"
    
    if (( $(echo "$SUCCESS_RATE > 95" | bc -l) )); then
        echo -e "${GREEN}✓ Excellent success rate${NC}"
    elif (( $(echo "$SUCCESS_RATE > 90" | bc -l) )); then
        echo -e "${YELLOW}⚠ Good success rate${NC}"
    else
        echo -e "${RED}✗ Low success rate - needs attention${NC}"
    fi
else
    echo "No transactions in last 24 hours"
fi
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              Report Complete                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
