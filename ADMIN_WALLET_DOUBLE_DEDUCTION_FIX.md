# Admin Wallet Double Deduction Fix

## Problem Statement

When a merchant processes a payout, the system was incorrectly deducting from BOTH:
1. ✅ Merchant wallet (CORRECT - this should happen)
2. ❌ Admin wallet (INCORRECT - this should NOT happen)

This caused the admin wallet balance to be incorrectly reduced by merchant payout amounts.

## Root Cause

In `wallet_service.py` and `wallet_routes.py`, the admin wallet balance calculation included ALL payouts:

```python
# INCORRECT CODE (Before Fix)
cursor.execute("""
    SELECT COALESCE(SUM(amount), 0) as total_payout
    FROM payout_transactions
    WHERE status IN ('SUCCESS', 'QUEUED')
""")
# This includes BOTH admin AND merchant payouts
```

## Solution

### 1. Updated Wallet Service (`backend/wallet_service.py`)

Changed the admin wallet balance calculation to ONLY include admin personal payouts:

```python
# CORRECT CODE (After Fix)
cursor.execute("""
    SELECT COALESCE(SUM(amount), 0) as total_payout
    FROM payout_transactions
    WHERE status IN ('SUCCESS', 'QUEUED')
    AND reference_id LIKE 'ADMIN%'
""")
# Now only includes admin payouts (reference_id starts with 'ADMIN')
```

### 2. Updated Wallet Routes (`backend/wallet_routes.py`)

Applied the same fix to the admin wallet overview endpoint.

### 3. How to Identify Payout Types

- **Admin Payouts**: `reference_id` starts with `'ADMIN'` (e.g., `ADMIN20260227123456ABC123`)
- **Merchant Payouts**: `reference_id` starts with `'SF'` (e.g., `SF20260227123456ABC123`)

## Admin Wallet Balance Formula

### Before Fix (INCORRECT)
```
Admin Balance = PayIN + Fetch - Topups - ALL Payouts
                                          ^^^^^^^^^^^
                                          (includes merchant payouts - WRONG!)
```

### After Fix (CORRECT)
```
Admin Balance = PayIN + Fetch - Topups - Admin Payouts Only
                                          ^^^^^^^^^^^^^^^^^^
                                          (excludes merchant payouts - CORRECT!)
```

Where:
- **PayIN**: Successful payin transactions (credits to admin)
- **Fetch**: Funds fetched from merchants (credits to admin)
- **Topups**: Fund requests approved for merchants (debits from admin)
- **Admin Payouts**: Personal payouts made by admin (debits from admin)
- **Merchant Payouts**: Payouts made by merchants (should NOT affect admin wallet)

## Fixing Historical Data

### Script: `backend/fix_admin_wallet_merchant_payouts.py`

This script:
1. Identifies all merchant payouts (reference_id NOT starting with 'ADMIN')
2. Calculates total amount incorrectly debited from admin wallet
3. Creates corrective CREDIT entries in `admin_wallet_transactions`
4. Restores admin wallet to correct balance

### How to Run

```bash
cd backend
python fix_admin_wallet_merchant_payouts.py
```

### What It Does

1. **Identifies Merchant Payouts**:
   ```sql
   SELECT * FROM payout_transactions
   WHERE status IN ('SUCCESS', 'QUEUED')
   AND reference_id NOT LIKE 'ADMIN%'
   ```

2. **Calculates Correction Amount**:
   - Sums up all merchant payout amounts
   - Shows current (incorrect) vs corrected balance

3. **Creates Corrective Entries**:
   - Inserts CREDIT entries in `admin_wallet_transactions`
   - Description: "Correction: Merchant payout {txn_id} should not debit admin wallet"
   - Reference: Original payout reference_id

4. **Confirms Before Proceeding**:
   - Shows summary of changes
   - Asks for user confirmation
   - Can be cancelled safely

### Example Output

```
================================================================================
Fix Admin Wallet - Remove Merchant Payout Deductions
================================================================================

Step 1: Identifying merchant payouts...
Found 5 merchant payout(s)

Merchant Payouts Summary:
--------------------------------------------------------------------------------
  TXN: TXN123ABC456DEF
  Merchant: MERCH001
  Amount: ₹500.00
  Status: SUCCESS
  Date: 2026-02-27 10:30:00

  TXN: TXN789GHI012JKL
  Merchant: MERCH002
  Amount: ₹1000.00
  Status: SUCCESS
  Date: 2026-02-27 11:45:00

Total amount incorrectly debited from admin wallet: ₹1500.00

Step 2: Calculating current admin balance...
  PayIN Amount: ₹50000.00
  Fetch Amount: ₹5000.00
  Topup Amount: ₹20000.00
  Admin Payouts: ₹2000.00
  Merchant Payouts (incorrect): ₹1500.00

  Current Balance (BEFORE fix): ₹31500.00
  Corrected Balance (AFTER fix): ₹33000.00
  Difference: ₹1500.00

⚠️  WARNING: This will create corrective credit entries in admin_wallet_transactions
⚠️  Total credit to be added: ₹1500.00

Do you want to proceed? (yes/no): yes

Step 3: Creating corrective credit entries...
  ✓ Created credit entry: AWT20260227150000123ABC - ₹500.00
  ✓ Created credit entry: AWT20260227150001789GHI - ₹1000.00

================================================================================
✅ Fix completed successfully!
================================================================================

Total corrective credits added: ₹1500.00
Admin wallet balance corrected from ₹31500.00 to ₹33000.00

Note: The wallet service has been updated to exclude merchant payouts
      from admin wallet calculations going forward.
```

## Files Modified

1. **backend/wallet_service.py**
   - Function: `debit_admin_wallet()`
   - Changed payout query to filter by `reference_id LIKE 'ADMIN%'`

2. **backend/wallet_routes.py**
   - Function: `get_admin_wallet_overview()`
   - Changed payout query to filter by `reference_id LIKE 'ADMIN%'`

3. **backend/fix_admin_wallet_merchant_payouts.py** (NEW)
   - Script to fix historical data
   - Creates corrective credit entries

## Testing

### 1. Test Current Behavior (After Fix)

```bash
# Merchant makes a payout
curl -X POST http://localhost:5000/api/payout/client/settle-fund \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "bank_id": 1,
    "amount": 500,
    "tpin": "1234"
  }'

# Check merchant wallet - should be debited
# Check admin wallet - should NOT be affected
```

### 2. Verify Admin Wallet Balance

```bash
# Get admin wallet overview
curl -X GET http://localhost:5000/api/wallet/admin/overview \
  -H "Authorization: Bearer {admin_token}"

# Should show correct balance excluding merchant payouts
```

### 3. Verify Historical Fix

```bash
# Run the fix script
cd backend
python fix_admin_wallet_merchant_payouts.py

# Check admin_wallet_transactions table
# Should see corrective CREDIT entries
```

## Database Queries for Verification

### Check Merchant Payouts
```sql
SELECT 
    txn_id,
    reference_id,
    merchant_id,
    amount,
    status,
    created_at
FROM payout_transactions
WHERE status IN ('SUCCESS', 'QUEUED')
AND reference_id NOT LIKE 'ADMIN%'
ORDER BY created_at DESC;
```

### Check Admin Payouts
```sql
SELECT 
    txn_id,
    reference_id,
    merchant_id,
    amount,
    status,
    created_at
FROM payout_transactions
WHERE status IN ('SUCCESS', 'QUEUED')
AND reference_id LIKE 'ADMIN%'
ORDER BY created_at DESC;
```

### Check Admin Wallet Transactions
```sql
SELECT 
    txn_id,
    txn_type,
    amount,
    balance_before,
    balance_after,
    description,
    reference_id,
    created_at
FROM admin_wallet_transactions
ORDER BY created_at DESC
LIMIT 20;
```

### Calculate Admin Balance Manually
```sql
-- PayIN
SELECT COALESCE(SUM(amount), 0) as total_payin
FROM payin_transactions
WHERE status = 'SUCCESS';

-- Topups
SELECT COALESCE(SUM(amount), 0) as total_topup
FROM fund_requests
WHERE status = 'APPROVED';

-- Fetch
SELECT COALESCE(SUM(amount), 0) as total_fetch
FROM merchant_wallet_transactions
WHERE txn_type = 'DEBIT' 
AND description LIKE '%fetched by admin%';

-- Admin Payouts ONLY
SELECT COALESCE(SUM(amount), 0) as total_admin_payout
FROM payout_transactions
WHERE status IN ('SUCCESS', 'QUEUED')
AND reference_id LIKE 'ADMIN%';

-- Balance = PayIN + Fetch - Topups - Admin Payouts
```

## Deployment

### Step 1: Deploy Code Changes
```bash
# Deploy updated wallet service and routes
scp backend/wallet_service.py ubuntu@13.127.135.229:/home/ubuntu/moneyone/backend/
scp backend/wallet_routes.py ubuntu@13.127.135.229:/home/ubuntu/moneyone/backend/

# Restart backend
ssh ubuntu@13.127.135.229
cd /home/ubuntu/moneyone/backend
sudo systemctl restart moneyone-backend
```

### Step 2: Fix Historical Data
```bash
# Copy fix script to server
scp backend/fix_admin_wallet_merchant_payouts.py ubuntu@13.127.135.229:/home/ubuntu/moneyone/backend/

# Run fix script on server
ssh ubuntu@13.127.135.229
cd /home/ubuntu/moneyone/backend
python fix_admin_wallet_merchant_payouts.py
```

## Rollback Plan

If issues occur:

1. **Restore Old Files**:
   ```bash
   # Restore from backup
   cp wallet_service.py.backup wallet_service.py
   cp wallet_routes.py.backup wallet_routes.py
   sudo systemctl restart moneyone-backend
   ```

2. **Remove Corrective Entries** (if needed):
   ```sql
   DELETE FROM admin_wallet_transactions
   WHERE description LIKE 'Correction: Merchant payout%';
   ```

## Impact

### Before Fix
- ❌ Admin wallet incorrectly reduced by merchant payouts
- ❌ Admin balance showed less than actual
- ❌ Could lead to "insufficient balance" errors for admin

### After Fix
- ✅ Admin wallet only affected by admin personal payouts
- ✅ Admin balance shows correct amount
- ✅ Merchant payouts only affect merchant wallets
- ✅ Historical data corrected with audit trail

## Notes

- The fix is backward compatible
- Corrective entries are clearly marked in description
- Original payout records are not modified
- Admin wallet transactions table maintains complete audit trail
- The fix script can be run multiple times safely (it will show 0 corrections if already fixed)
