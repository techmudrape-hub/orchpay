# Backfill Merchant Payout Wallet Deduction Guide (TODAY ONLY)

## Overview
This script backfills missing wallet deductions for TODAY's successful payouts for a specific merchant. It prevents double deduction by checking if wallet transactions already exist.

## When to Use
- When a merchant's successful payouts from TODAY show SUCCESS status but wallet wasn't deducted
- After fixing the direct payout wallet deduction bug
- When you need to reconcile wallet balances for today's transactions only

## Features
- ✅ Processes only TODAY's successful payouts (status = 'SUCCESS', completed today)
- ✅ Prevents double deduction by checking existing wallet transactions
- ✅ Dry run mode to preview changes before applying
- ✅ Detailed logging of each transaction
- ✅ Shows before/after wallet balances
- ✅ Safe rollback on errors

## Usage

### 1. Dry Run (Preview Only)
```bash
cd /home/ubuntu/moneyone_backend
python3 backfill_merchant_payout_wallet.py <merchant_id>
```

Example:
```bash
python3 backfill_merchant_payout_wallet.py 9000000001
```

This will show you:
- Current wallet balance
- List of successful payouts without wallet deductions
- Total amount that would be deducted
- No changes are made to the database

### 2. Live Run (Apply Changes)
```bash
python3 backfill_merchant_payout_wallet.py <merchant_id> --live
```

Example:
```bash
python3 backfill_merchant_payout_wallet.py 9000000001 --live
```

You'll be prompted to confirm before changes are applied.

## Output Example

### Dry Run Output
```
================================================================================
Backfill Payout Wallet Deductions (TODAY ONLY)
================================================================================
Merchant ID: 9000000001
Business Name: Test Merchant
Mode: DRY RUN (no changes)
================================================================================

Current Wallet Balance:
  Settled: ₹50000.00
  Unsettled: ₹10000.00

================================================================================
Finding TODAY's successful payouts without wallet deductions...
================================================================================

Processing payouts for: 2026-03-09

Found 2 successful payout(s) from TODAY without wallet deduction:

1. Transaction: TXN123ABC456DEF
   Reference ID: DP20260309120000ABC123
   Order ID: ORDER_1234567890
   Amount: ₹1100.00
   Charges: ₹100.00
   Net to Bank: ₹1000.00
   PG Partner: MUDRAPE
   Created: 2026-03-09 12:00:00
   Completed: 2026-03-09 12:00:05
   🔍 WOULD DEDUCT: ₹1100.00 from settled wallet

2. Transaction: TXN789GHI012JKL
   Reference ID: DP20260309130000DEF456
   Order ID: ORDER_9876543210
   Amount: ₹550.00
   Charges: ₹50.00
   Net to Bank: ₹500.00
   PG Partner: MUDRAPE
   Created: 2026-03-09 13:00:00
   Completed: 2026-03-09 13:00:03
   🔍 WOULD DEDUCT: ₹550.00 from settled wallet

================================================================================
Summary
================================================================================
Total Payouts Found: 2
Processed: 2
Skipped: 0
Total Amount to Deduct: ₹1650.00

⚠️  DRY RUN MODE - No changes were made
Run with --live flag to apply changes
================================================================================
```

### Live Run Output
```
⚠️  WARNING: Running in LIVE mode. Changes will be applied to the database.
Are you sure you want to continue? (yes/no): yes

================================================================================
Backfill Payout Wallet Deductions (TODAY ONLY)
================================================================================
Merchant ID: 9000000001
Business Name: Test Merchant
Mode: LIVE (will make changes)
================================================================================

Current Wallet Balance:
  Settled: ₹50000.00
  Unsettled: ₹10000.00

================================================================================
Finding TODAY's successful payouts without wallet deductions...
================================================================================

Processing payouts for: 2026-03-09

Found 2 successful payout(s) from TODAY without wallet deduction:

1. Transaction: TXN123ABC456DEF
   ...
   ✅ DEDUCTED: ₹1100.00 from settled wallet

2. Transaction: TXN789GHI012JKL
   ...
   ✅ DEDUCTED: ₹550.00 from settled wallet

================================================================================
Summary
================================================================================
Total Payouts Found: 2
Processed: 2
Skipped: 0
Total Amount to Deduct: ₹1650.00

✅ Wallet deductions applied successfully

Updated Wallet Balance:
  Settled: ₹48350.00
  Unsettled: ₹10000.00
================================================================================
```

## How It Works

### 1. Find Missing Deductions (TODAY ONLY)
The script queries for TODAY's successful payouts that don't have corresponding wallet debit transactions:
```sql
SELECT p.*
FROM payout_transactions p
LEFT JOIN merchant_wallet_transactions w 
    ON w.reference_id = p.txn_id 
    AND w.txn_type = 'DEBIT'
WHERE p.merchant_id = ?
    AND p.status = 'SUCCESS'
    AND p.completed_at IS NOT NULL
    AND DATE(p.completed_at) = CURDATE()  -- TODAY ONLY
    AND w.id IS NULL
```

### 2. Double Deduction Prevention
Before deducting, it double-checks if a wallet transaction already exists:
```sql
SELECT * FROM merchant_wallet_transactions
WHERE merchant_id = ? 
    AND reference_id = ? 
    AND txn_type = 'DEBIT'
```

If found, the transaction is skipped with a warning.

### 3. Apply Deduction
For each missing deduction:
1. Insert wallet transaction record
2. Update merchant wallet balance
3. Commit transaction (or rollback on error)

## Verification

### Check Specific Merchant's Payouts
```sql
-- Find successful payouts without wallet deductions
SELECT 
    p.txn_id,
    p.reference_id,
    p.order_id,
    p.amount,
    p.status,
    p.completed_at,
    COUNT(w.id) as wallet_txn_count
FROM payout_transactions p
LEFT JOIN merchant_wallet_transactions w 
    ON w.reference_id = p.txn_id 
    AND w.txn_type = 'DEBIT'
WHERE p.merchant_id = '9000000001'
    AND p.status = 'SUCCESS'
GROUP BY p.txn_id
HAVING wallet_txn_count = 0;
```

### Check Wallet Balance
```sql
SELECT 
    merchant_id,
    settled_balance,
    unsettled_balance,
    updated_at
FROM merchant_wallet
WHERE merchant_id = '9000000001';
```

### Check Recent Wallet Transactions
```sql
SELECT 
    id,
    merchant_id,
    amount,
    txn_type,
    description,
    reference_id,
    created_at
FROM merchant_wallet_transactions
WHERE merchant_id = '9000000001'
ORDER BY created_at DESC
LIMIT 10;
```

## Safety Features

### 1. Dry Run by Default
The script runs in dry run mode by default, showing what would happen without making changes.

### 2. Confirmation Prompt
When running in live mode, you must type "yes" to confirm.

### 3. Double Deduction Check
Each transaction is checked twice to ensure no duplicate deductions.

### 4. Transaction Rollback
If any error occurs during deduction, the transaction is rolled back.

### 5. Detailed Logging
Every action is logged with clear status indicators:
- 🔍 Would deduct (dry run)
- ✅ Deducted successfully
- ⚠️ Skipped (already exists)
- ❌ Error occurred

## Common Scenarios

### Scenario 1: All Payouts Already Deducted
```
Found 0 successful payout(s) without wallet deduction

✅ No missing wallet deductions found. All successful payouts have been deducted.
```

### Scenario 2: Some Already Deducted
```
1. Transaction: TXN123...
   ⚠️  SKIPPED - Wallet transaction already exists (ID: 12345)
       Amount: ₹1100.00
       Created: 2026-03-09 12:00:10

Summary:
Total Payouts Found: 5
Processed: 3
Skipped: 2
```

### Scenario 3: Merchant Not Found
```
❌ Merchant 9999999999 not found
```

## Troubleshooting

### Issue: Script shows 0 missing deductions but wallet seems wrong
**Solution:** Check if payouts are actually marked as SUCCESS:
```sql
SELECT status, COUNT(*) 
FROM payout_transactions 
WHERE merchant_id = '9000000001'
GROUP BY status;
```

### Issue: Wallet balance becomes negative
**Solution:** This means the merchant doesn't have enough balance. Check:
1. Current settled balance
2. Total amount to be deducted
3. Whether merchant should have this balance

### Issue: Database connection error
**Solution:** Check database credentials in `backend/.env`:
```bash
cat backend/.env | grep DB_
```

## Best Practices

1. **Always run dry run first** to preview changes
2. **Verify merchant ID** before running live mode
3. **Check wallet balance** to ensure sufficient funds
4. **Run during low traffic** to avoid conflicts
5. **Keep logs** of what was processed
6. **Verify results** after running in live mode

## Integration with Monitoring

### Add to Cron for Regular Checks
```bash
# Check all merchants daily at 2 AM
0 2 * * * cd /home/ubuntu/moneyone_backend && python3 check_all_merchants_wallet.py >> /var/log/wallet_check.log 2>&1
```

### Create Alert Script
```bash
#!/bin/bash
# alert_missing_deductions.sh
MERCHANT_ID=$1
OUTPUT=$(python3 backfill_merchant_payout_wallet.py $MERCHANT_ID)
COUNT=$(echo "$OUTPUT" | grep "Total Payouts Found:" | awk '{print $4}')

if [ "$COUNT" -gt 0 ]; then
    echo "⚠️ Alert: $COUNT missing wallet deductions for merchant $MERCHANT_ID"
    # Send notification (email, Slack, etc.)
fi
```

## Related Scripts
- `backend/backfill_missing_payout_deductions.py` - Backfill for all merchants
- `backend/verify_payout_wallet_deduction.py` - Verify wallet deductions
- `backend/check_merchant_wallet_issue.py` - Diagnose wallet issues

## Support
If you encounter issues:
1. Check the error message in the output
2. Review database logs: `sudo journalctl -u mysql -f`
3. Check backend logs: `sudo journalctl -u moneyone-backend -f`
4. Verify database connectivity: `python3 backend/test_db_connection.py`
