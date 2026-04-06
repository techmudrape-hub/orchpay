# Check Payout Status - All PG Partners Support

## Problem
The `/api/payout/client/check-status/<txn_id>` endpoint was returning error:
```json
{
  "message": "Only Mudrape transactions can be checked",
  "success": false
}
```

This prevented merchants from checking PayTouch and TourQuest payout statuses.

## Root Cause

The `client_check_payout_status` function in `payout_routes.py` had a hardcoded check:

```python
if txn['pg_partner'] != 'Mudrape':
    return jsonify({'success': False, 'message': 'Only Mudrape transactions can be checked'}), 400
```

This blocked all non-Mudrape transactions.

## Fix Applied

Updated the function to support all PG partners:

```python
# Check status based on PG partner
if txn['pg_partner'] == 'Mudrape':
    status_result = mudrape_service.check_payout_status(txn['reference_id'])
elif txn['pg_partner'] == 'PayTouch':
    status_result = paytouch_service.check_payout_status(
        transaction_id=txn['pg_txn_id'],
        external_ref=txn['reference_id']
    )
elif txn['pg_partner'] == 'TourQuest':
    status_result = tourquest_service.check_payout_status(txn['reference_id'])
else:
    return jsonify({
        'success': False, 
        'message': f'Status check not supported for {txn["pg_partner"]}'
    }), 400
```

## Deployment

### Quick Deploy

```bash
chmod +x deploy_check_status_all_pg.sh
./deploy_check_status_all_pg.sh
```

### Manual Steps

```bash
cd /home/ubuntu/moneyone_backend
sudo systemctl restart moneyone_backend
```

## API Usage

### Endpoint
```
POST /api/payout/client/check-status/<txn_id>
```

### Headers
```
Authorization: Bearer <merchant_jwt_token>
```

### Example Request (Mudrape)
```bash
curl -X POST https://api.orchpay.in/api/payout/client/check-status/TXN123ABC \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json"
```

### Example Request (PayTouch)
```bash
curl -X POST https://api.orchpay.in/api/payout/client/check-status/TXN986649FDE8 \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json"
```

### Success Response
```json
{
  "success": true,
  "message": "Status checked and updated successfully",
  "data": {
    "txn_id": "TXN986649FDE8",
    "reference_id": "ADMIN20250306083800ABC123",
    "amount": 100.0,
    "status": "SUCCESS",
    "utr": "123456789012",
    "pg_txn_id": "PT_TXN_123",
    "pg_partner": "PayTouch",
    "created_at": "2025-03-06 08:38:00",
    "completed_at": "2025-03-06 08:38:15"
  }
}
```

### Error Response (Transaction Not Found)
```json
{
  "success": false,
  "message": "Transaction not found or unauthorized"
}
```

### Error Response (Unsupported PG Partner)
```json
{
  "success": false,
  "message": "Status check not supported for XYZ"
}
```

## Supported PG Partners

| PG Partner | Status Check | Method |
|------------|--------------|--------|
| Mudrape | ✅ Supported | Uses `reference_id` |
| PayTouch | ✅ Supported | Uses `pg_txn_id` + `reference_id` |
| TourQuest | ✅ Supported | Uses `reference_id` |
| Others | ❌ Not supported | Returns error message |

## What Happens When Status is Checked

1. **Merchant calls endpoint** with their JWT token and txn_id
2. **System verifies** transaction belongs to merchant
3. **Calls PG partner API** to get latest status
4. **Updates database** with new status, UTR, timestamps
5. **Returns updated data** to merchant

## Database Updates

The endpoint automatically updates:
- `status` - Latest status from PG partner
- `utr` - Bank reference number (if available)
- `pg_txn_id` - PG partner transaction ID
- `completed_at` - Completion timestamp (for SUCCESS/FAILED)
- `updated_at` - Last update timestamp

## Files Modified

1. `backend/payout_routes.py` - Updated `client_check_payout_status` function
2. `deploy_check_status_all_pg.sh` - Deployment script
3. `CHECK_STATUS_ALL_PG_FIX.md` - This documentation

## Testing

### Test Mudrape Transaction
```bash
# Get a Mudrape txn_id from your payout report
curl -X POST https://api.orchpay.in/api/payout/client/check-status/TXN_MUDRAPE_123 \
  -H "Authorization: Bearer <merchant_token>"
```

### Test PayTouch Transaction
```bash
# Get a PayTouch txn_id from your payout report
curl -X POST https://api.orchpay.in/api/payout/client/check-status/TXN986649FDE8 \
  -H "Authorization: Bearer <merchant_token>"
```

### Test TourQuest Transaction
```bash
# Get a TourQuest txn_id from your payout report
curl -X POST https://api.orchpay.in/api/payout/client/check-status/TXN_TOURQUEST_123 \
  -H "Authorization: Bearer <merchant_token>"
```

## Expected Results

After fix:
- ✅ Mudrape transactions can be checked
- ✅ PayTouch transactions can be checked
- ✅ TourQuest transactions can be checked
- ✅ Database automatically updates with latest status
- ✅ Merchants get real-time status updates

## Security

- ✅ Merchants can only check their own transactions
- ✅ JWT authentication required
- ✅ Transaction ownership verified before status check
- ✅ Unauthorized access returns 404 error

## Summary

The check status endpoint now supports all PG partners (Mudrape, PayTouch, TourQuest) instead of being restricted to Mudrape only. Merchants can now check the status of any payout transaction regardless of which PG partner was used.
