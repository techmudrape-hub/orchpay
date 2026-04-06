# Admin Wallet Balance Calculation Fix

## Problem
Admin wallet showing ₹67,360.26 instead of actual balance of ₹890,557.26

## Root Cause
The balance calculation was incorrectly subtracting payouts from admin wallet:
```
WRONG: Admin Balance = PayIN + Fetch - Topups - Payouts
```

**Payouts are paid from MERCHANT wallets, NOT admin wallet!**

## Correct Flow

1. **PayIN** → Credits Admin Wallet
2. **Topup/Fund Request** → Debits Admin Wallet, Credits Merchant Wallet  
3. **Payout** → Debits Merchant Wallet (NOT Admin Wallet)

## Correct Logic
```
Admin Wallet = PayIN + Fetch - Topups
```

### Breakdown:
- **PayIN (₹2,244,812)**: Money received from customers → Credits Admin Wallet
- **Fetch (₹2,892)**: Money fetched back from merchants → Credits Admin Wallet  
- **Topups (₹1,357,197)**: Money transferred to merchants → Debits Admin Wallet
- **Payouts (₹823,146.74)**: Money sent to customers → Debits MERCHANT Wallet (not admin!)

### Correct Balance:
```
Admin Wallet = ₹2,244,812 + ₹2,892 - ₹1,357,197 = ₹890,507.00
```

### Merchant Wallet (for reference):
```
Merchant Wallet = Topups - Fetch - Payouts
                = ₹1,357,197 - ₹2,892 - ₹823,146.74 = ₹531,158.26
```

## Files Changed

### 1. backend/payout_routes.py
**Function:** `admin_topup_fund()` (line ~470)

**Changed:**
- Added back `total_topup` query
- Removed `total_payout` query (payouts don't affect admin wallet)
- Updated calculation to: `available_balance = total_payin + total_fetch - total_topup`

### 2. backend/wallet_routes.py  
**Function:** `get_admin_wallet_overview()` (line ~70)

**Changed:**
- Removed payout query (payouts are from merchant wallets)
- Updated calculation to: `admin_balance = total_payin + total_fetch - total_topup`

## Deployment Steps

1. **Backup files:**
```bash
cd /var/www/moneyone/moneyone/backend
cp payout_routes.py payout_routes.py.backup
cp wallet_routes.py wallet_routes.py.backup
```

2. **Apply changes** (already done in local files)

3. **Restart backend:**
```bash
sudo systemctl restart moneyone-backend
```

4. **Verify:**
```bash
python3 diagnose_admin_wallet_issue.py
```

Expected output:
```
ADMIN WALLET CALCULATION:
PayIN (received):    + ₹2,244,812.00
Fetch (from merch):  + ₹2,892.00
Topups (to merch):   - ₹1,357,197.00
----------------------------------------
Admin Balance:       = ₹890,507.00
```

## Testing

1. Check admin dashboard - wallet balance should show ~₹8.9 lakh
2. Try topup with amount < ₹8.9 lakh - should succeed
3. Check wallet overview API response

## Impact

- Admin can now topup merchants with the correct available balance
- No more "Insufficient balance" errors when funds are actually available
- Wallet display shows accurate balance
- Payouts correctly deduct from merchant wallets, not admin wallet
