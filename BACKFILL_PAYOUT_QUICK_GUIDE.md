# Quick Guide: Backfill Missing Payout Deductions

## What This Fixes
SUCCESS payouts that went to the bank but didn't deduct from merchant's settled wallet due to the callback bug.

## Quick Start

### 1. Analyze (See What's Affected)
```bash
cd /var/www/moneyone/backend
python3 backfill_missing_payout_deductions.py --analyze
```

Shows:
- Which merchants are affected
- How many transactions per merchant
- Total amount to deduct
- Current wallet balances
- Whether they have sufficient balance

### 2. Dry Run (Preview Changes)
```bash
python3 backfill_missing_payout_deductions.py
```

Shows exactly what will be fixed without making any changes.

### 3. Apply Fix (Live Mode)
```bash
python3 backfill_missing_payout_deductions.py --live
```

Actually deducts the wallet balances. Requires typing 'YES' to confirm.

## Options

### Fix Specific Date
```bash
# Fix transactions from March 7, 2026
python3 backfill_missing_payout_deductions.py --date 2026-03-07 --live
```

### Analyze Specific Date
```bash
python3 backfill_missing_payout_deductions.py --analyze --date 2026-03-07
```

## Using the Shell Script

```bash
# Interactive script that guides you through the process
./fix_today_payout_balances.sh
```

This script:
1. Shows analysis
2. Shows dry run
3. Asks for confirmation
4. Applies fixes

## What Gets Fixed

The script finds:
- Payout transactions with status = SUCCESS
- From PayTouch or Mudrape gateways
- That have NO corresponding wallet deduction (DEBIT transaction)
- From the specified date (default: today)

Then it:
- Debits the merchant's settled wallet
- Creates a wallet transaction record
- Uses the correct amount (payout + charges)

## Safety Features

1. **Dry Run Default:** Won't make changes unless you use `--live`
2. **Confirmation Required:** Asks you to type 'YES' before proceeding
3. **Balance Check:** Verifies merchant has sufficient balance
4. **Duplicate Prevention:** Won't deduct if wallet transaction already exists
5. **Detailed Logging:** Shows exactly what's happening for each transaction

## Example Output

### Analyze Mode
```
Merchant: 9000000001
  Missing Deductions: 2 transactions
  Total to Deduct: ₹10,500.00
  Current Settled Balance: ₹50,000.00
  Current Unsettled Balance: ₹5,000.00
  Status: ✓ Sufficient balance
```

### Dry Run Mode
```
Transaction: TXN123ABC456DEF
  Reference: DP20260307123456ABC123
  Merchant: 9000000001
  PG Partner: Mudrape
  Amount to Deduct: ₹10,500.00
    - Net Amount: ₹10,000.00
    - Charges: ₹500.00
  Completed: 2026-03-07 14:30:00
```

### Live Mode
```
Processing: TXN123ABC456DEF
  Merchant: 9000000001
  Deducting: ₹10,500.00
  Current Settled Balance: ₹50,000.00
  ✓ Wallet debited successfully
    Balance: ₹50,000.00 → ₹39,500.00
```

## Troubleshooting

### Insufficient Balance Error
```
✗ ERROR: Insufficient balance (need ₹10,500.00, have ₹5,000.00)
⚠️  This payout was successful but merchant doesn't have enough balance now!
⚠️  Manual intervention required - contact merchant or admin
```

**Solution:**
1. Contact merchant to understand why balance is low
2. Options:
   - Merchant adds funds to wallet
   - Admin credits merchant wallet manually
   - Document as exception if legitimate reason

### Wallet Not Found
```
✗ ERROR: Wallet not found for merchant 9000000001
```

**Solution:**
Check if merchant exists and has a wallet record in `merchant_wallet` table.

## Verification

After running the fix, verify:

### 1. Check Wallet Transactions
```sql
SELECT * FROM merchant_wallet_transactions
WHERE reference_id = 'TXN_ID'
AND txn_type = 'DEBIT'
AND description LIKE '%Backfill%';
```

### 2. Check Merchant Balance
```sql
SELECT merchant_id, settled_balance, unsettled_balance, balance, last_updated
FROM merchant_wallet
WHERE merchant_id = 'MERCHANT_ID';
```

### 3. Verify No More Missing Deductions
```bash
python3 backfill_missing_payout_deductions.py --analyze
```

Should show "No affected merchants found" if all fixed.

## When to Use

- **After deploying the callback fix:** To fix transactions that happened before the fix
- **Daily reconciliation:** Check if any transactions were missed
- **After system issues:** If callbacks were not processed due to downtime
- **Manual verification:** When merchant reports balance discrepancy

## Important Notes

1. **Run during low traffic:** To avoid conflicts with live transactions
2. **Backup first:** Consider backing up wallet tables before running live mode
3. **One date at a time:** Process one day at a time for easier tracking
4. **Monitor logs:** Watch backend logs during and after execution
5. **Communicate with merchants:** Inform affected merchants about the correction

## Files

- `backend/backfill_missing_payout_deductions.py` - Main script
- `fix_today_payout_balances.sh` - Interactive shell script
- `PAYOUT_SETTLED_WALLET_DEDUCTION_FIX.md` - Complete documentation

## Support

If you encounter issues:
1. Check backend logs: `tail -f /var/www/moneyone/logs/backend.log`
2. Review database state: Use SQL queries above
3. Contact system administrator
4. Document any manual interventions made
