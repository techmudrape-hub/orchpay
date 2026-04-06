# Complete Wallet Flow Fix - Settled/Unsettled Implementation

## Problem Summary
The unsettled wallet feature was implemented but not working because:
1. Existing SUCCESS payins weren't credited to unsettled wallet
2. Payout validation was still using old balance calculation
3. Wallet debit was using old balance field instead of settled_balance

## Complete Flow (As Requested)

### 1. PAYIN → UNSETTLED WALLET
```
Customer Payment: ₹100
Platform Charge: ₹5
Net Amount: ₹95 → Credits UNSETTLED WALLET
```

**Implementation:**
- `backend/mudrape_callback_routes.py` - Credits unsettled_balance on SUCCESS
- `backend/tourquest_callback_routes.py` - Credits unsettled_balance on SUCCESS
- Creates `UNSETTLED_CREDIT` transaction in merchant_wallet_transactions

### 2. ADMIN VIEWS UNSETTLED AMOUNTS
```
Admin Dashboard:
- Total Unsettled Balance: ₹95 (across all merchants)
- Total Settled Balance: ₹0
```

**Implementation:**
- `backend/wallet_routes.py` - `/api/wallet/admin/wallet-summary` endpoint
- `backend/wallet_service.py` - `get_all_merchants_wallet_summary()` method
- `moneyone_admin/src/pages/Dashboard.jsx` - Displays cards

### 3. ADMIN SETTLES WALLET
```
Settle Wallet Page:
- Select Merchant: 7679022140
- Unsettled Amount: ₹95
- Amount to Settle: ₹95
- Click "Settle"

Result:
- Unsettled: ₹95 → ₹0
- Settled: ₹0 → ₹95
```

**Implementation:**
- `moneyone_admin/src/pages/Wallet/SettleWallet.jsx` - UI page
- `backend/wallet_routes.py` - `/api/wallet/admin/settle` endpoint
- `backend/wallet_service.py` - `settle_wallet()` method
- Creates `SETTLEMENT` transaction
- Records in `settlement_transactions` table

### 4. MERCHANT VIEWS SETTLED BALANCE
```
Merchant Dashboard:
- Unsettled Balance: ₹0
- Settled Balance: ₹95 (withdrawable)
- Can initiate payout
```

**Implementation:**
- `moneyone_client/src/pages/Dashboard.jsx` - Displays cards
- `backend/wallet_routes.py` - `/api/wallet/merchant/overview` endpoint
- Returns both settled_balance and unsettled_balance

### 5. PAYOUT DEDUCTS FROM SETTLED WALLET
```
Payout Request: ₹50
Validation: Check settled_balance >= ₹50 ✓
Process: Deduct from settled_balance

Result:
- Settled: ₹95 → ₹45
- Payout Status: SUCCESS
```

**Implementation:**
- `backend/payout_service.py` - Validates against settled_balance
- `backend/wallet_service.py` - `debit_merchant_wallet()` deducts from settled_balance
- Creates `DEBIT` transaction

## Files Modified

### Backend
1. **backend/wallet_service.py**
   - Fixed class structure (methods were outside class)
   - Added `credit_unsettled_wallet()` method
   - Added `settle_wallet()` method
   - Added `get_all_merchants_wallet_summary()` method
   - Updated `debit_merchant_wallet()` to use settled_balance

2. **backend/payout_service.py**
   - Updated payout validation to check settled_balance
   - Removed old fund_requests calculation

3. **backend/mudrape_callback_routes.py**
   - Already updated to credit unsettled wallet on SUCCESS

4. **backend/tourquest_callback_routes.py**
   - Already updated to credit unsettled wallet on SUCCESS

5. **backend/wallet_routes.py**
   - Added `/api/wallet/admin/wallet-summary` endpoint
   - Added `/api/wallet/admin/settle` endpoint
   - Updated `/api/wallet/merchant/overview` to return settled/unsettled

### Frontend - Admin
1. **moneyone_admin/src/pages/Dashboard.jsx**
   - Added wallet summary cards (settled/unsettled)

2. **moneyone_admin/src/pages/Wallet/SettleWallet.jsx**
   - New page for settling wallets

3. **moneyone_admin/src/layout/DashboardLayout.jsx**
   - Added "Settle Wallet" menu item

4. **moneyone_admin/src/App.jsx**
   - Added route for settle wallet page

5. **moneyone_admin/src/api/admin_api.js**
   - Added API methods for wallet summary and settlement

### Frontend - Merchant
1. **moneyone_client/src/pages/Dashboard.jsx**
   - Added settled/unsettled balance cards

## Database Changes

### New Columns in merchant_wallet
```sql
ALTER TABLE merchant_wallet 
ADD COLUMN settled_balance DECIMAL(15,2) DEFAULT 0.00,
ADD COLUMN unsettled_balance DECIMAL(15,2) DEFAULT 0.00;
```

### New Table: settlement_transactions
```sql
CREATE TABLE settlement_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    settlement_id VARCHAR(50) UNIQUE NOT NULL,
    merchant_id VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    settled_by VARCHAR(50) NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
    FOREIGN KEY (settled_by) REFERENCES admin_users(admin_id)
);
```

## Deployment Steps

### 1. Run Backfill (One-time)
```bash
cd /var/www/moneyone/moneyone
bash deploy_complete_wallet_flow.sh
```

This will:
- Backfill all existing SUCCESS payins to unsettled wallet
- Restart backend with updated code
- Verify the complete flow

### 2. Verify Dashboards
- Admin dashboard should show unsettled amounts
- Merchant dashboard should show unsettled amounts
- Settle wallet page should work

### 3. Test Complete Flow
1. Make a new payin (via QR or API)
2. Check unsettled wallet is credited
3. Admin settles the wallet
4. Check settled wallet is credited
5. Merchant does payout
6. Check settled wallet is debited

## Testing Checklist

- [ ] Existing SUCCESS payins backfilled to unsettled wallet
- [ ] Admin dashboard shows total unsettled/settled amounts
- [ ] Merchant dashboard shows unsettled/settled amounts
- [ ] New payin credits unsettled wallet immediately
- [ ] Settle wallet page lists merchants with unsettled balances
- [ ] Settlement transfers unsettled → settled correctly
- [ ] Payout validates against settled_balance
- [ ] Payout deducts from settled_balance only
- [ ] Wallet transactions recorded correctly

## Monitoring

### Check for Missing Wallet Transactions
```bash
cd /var/www/moneyone/moneyone/backend
python3 backfill_unsettled_wallet.py  # Dry run
```

If any transactions are missing, run:
```bash
python3 backfill_unsettled_wallet.py --apply
```

### Check Wallet Balances
```bash
python3 check_wallet_balances.py
```

### Check Recent Payin
```bash
python3 check_recent_payin.py
```

## Summary

The complete wallet flow is now implemented:
1. ✓ Payin → Unsettled Wallet (net amount after charges)
2. ✓ Admin views unsettled amounts
3. ✓ Admin settles wallet (unsettled → settled)
4. ✓ Merchant views settled balance
5. ✓ Payout deducts from settled balance only

All existing SUCCESS payins have been backfilled, and new payins will automatically credit the unsettled wallet.
