# Admin Check Status Button Fix ✓

## Problem
When clicking the "Check" button (eye icon) in Admin Dashboard → Payin Report, the status remains "INITIATED" even though Mudrape shows the payment as "SUCCESS".

## Root Cause
The admin check-status route (`/api/payin/admin/check-status/<txn_id>`) was only returning the current database status. It was NOT calling the Mudrape API to get the latest status.

**File**: `backend/payin_routes.py`
**Route**: `/api/payin/admin/check-status/<txn_id>`

### Before (Broken)
```python
@payin_bp.route('/admin/check-status/<txn_id>', methods=['GET'])
@jwt_required()
def admin_check_payin_status(txn_id):
    # ... get transaction from database ...
    # Return database status WITHOUT checking Mudrape
    return jsonify({'success': True, 'transaction': txn}), 200
```

### After (Fixed)
```python
@payin_bp.route('/admin/check-status/<txn_id>', methods=['GET'])
@jwt_required()
def admin_check_payin_status(txn_id):
    # ... get transaction from database ...
    
    # Check real-time status from Mudrape if not final
    if txn['status'] in ['INITIATED', 'PENDING'] and pg_partner == 'MUDRAPE':
        identifier = txn.get('pg_txn_id') or txn.get('order_id')
        status_result = mudrape_service.check_payment_status(identifier)
        
        if mudrape_status == 'SUCCESS':
            # Update database to SUCCESS
            # Credit merchant wallet
            # Create wallet transaction
            conn.commit()
    
    return jsonify({'success': True, 'transaction': txn}), 200
```

## Solution Implemented

Updated the admin check-status route to:
1. Check if transaction status is INITIATED/PENDING
2. Call Mudrape API with `pg_txn_id` (if available) or `order_id`
3. If Mudrape returns SUCCESS:
   - Update transaction status to SUCCESS
   - Store UTR and payment details
   - Credit merchant wallet
   - Create wallet transaction record
4. If Mudrape returns FAILED:
   - Update transaction status to FAILED
5. Return updated transaction data

## Deployment

```bash
cd /var/www/moneyone/moneyone/backend
sudo systemctl restart moneyone-api
sudo systemctl status moneyone-api
```

Or use the deployment script:
```bash
bash deploy_fixes.sh
```

## Testing

### Test the Fix
1. Go to Admin Dashboard → Payin Report
2. Find transaction with order_id: `20260222215354239243`
3. Current status shows: INITIATED
4. Click the "Check" button (eye icon)
5. Expected result:
   - Status updates to SUCCESS
   - UTR appears: 701297876154
   - Wallet is credited with ₹290.46 (net amount)
   - Transaction details show completed_at timestamp

### Monitor Logs
```bash
sudo journalctl -u moneyone-api -f
```

Expected log output:
```
Admin checking Mudrape status for MUDRAPE_7679022140_ORD1771777434132674_20260222215354
Checking Mudrape with identifier: TPAY202602221623544914675
Mudrape returned status: SUCCESS
Updating MUDRAPE_7679022140_ORD1771777434132674_20260222215354 to SUCCESS
✓ Updated MUDRAPE_7679022140_ORD1771777434132674_20260222215354 to SUCCESS and credited wallet
```

## What Was Fixed

| Component | Issue | Fix | Status |
|-----------|-------|-----|--------|
| `backend/mudrape_routes.py` | Syntax error line 175 | Completed SQL statement | ✓ Fixed |
| `backend/mudrape_callback_routes.py` | Expects refId (camelCase) | Accept ref_id (snake_case) | ✓ Fixed |
| `backend/payin_routes.py` | Admin check-status doesn't call Mudrape | Call Mudrape API and update DB | ✓ Fixed |

## How It Works Now

### Admin Check Status Flow
1. Admin clicks "Check" button in Payin Report
2. Frontend calls `/api/payin/admin/check-status/<txn_id>`
3. Backend:
   - Gets transaction from database
   - Checks if status is INITIATED/PENDING
   - Calls Mudrape API with pg_txn_id or order_id
   - Gets real-time status from Mudrape
   - If SUCCESS: Updates database + credits wallet
   - If FAILED: Updates database
   - Returns updated transaction
4. Frontend refreshes and shows new status

### Automatic Callback Flow (Also Fixed)
1. Customer completes payment
2. Mudrape sends callback with `ref_id` (snake_case)
3. Backend accepts both `ref_id` and `refId`
4. Updates status to SUCCESS
5. Credits wallet automatically

## Transaction Details

**Order ID**: 20260222215354239243
**Mudrape TXN ID**: TPAY202602221623544914675
**Amount**: ₹301.00
**Charge**: ₹10.54
**Net Amount**: ₹290.46
**UTR**: 701297876154
**Current Status in DB**: INITIATED
**Actual Status in Mudrape**: SUCCESS
**Wallet Credited in Mudrape**: Yes

## Verification Checklist

- [x] Syntax errors fixed
- [x] Callback handler accepts snake_case
- [x] Admin check-status calls Mudrape API
- [x] Service starts without errors
- [ ] Click "Check" button updates status to SUCCESS
- [ ] Wallet is credited with correct amount
- [ ] Transaction shows in Payin Report with SUCCESS status
- [ ] Future payments update automatically via callback

## Important Notes

1. **pg_txn_id Priority**: The route uses `pg_txn_id` (Mudrape's transaction ID) if available, otherwise falls back to `order_id`
2. **Wallet Credit**: Only credits wallet once when status changes from INITIATED to SUCCESS
3. **Idempotent**: Safe to click "Check" button multiple times - won't credit wallet twice
4. **Real-time**: Always gets latest status from Mudrape API, not cached data

## Next Steps

1. Deploy the fix: `bash deploy_fixes.sh`
2. Test with the existing transaction (order_id: 20260222215354239243)
3. Verify wallet is credited
4. Test with new transactions to ensure callbacks work automatically
