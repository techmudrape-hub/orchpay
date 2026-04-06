# Airpay Callback Complete Fix

## Problem
The Airpay callback handler was not:
1. Updating transaction status in the database
2. Crediting merchant and admin wallets
3. Forwarding callbacks to merchant URLs

## Root Cause
The callback handler was not following the same pattern as Mudrape, which has a proven working flow.

## Solution Applied
Rewrote the Airpay callback handler to match the Mudrape callback flow exactly:

### Key Changes

1. **Merchant Callback URL Lookup**
   - Changed from: Reading `callback_url` from `payin_transactions` table
   - Changed to: Querying `merchant_callbacks` table for active callback URL
   - This matches how Mudrape handles merchant callbacks

2. **Callback Flow Structure**
   ```
   1. Receive encrypted callback from Airpay
   2. Decrypt the callback data
   3. Extract transaction data from nested 'data' field
   4. Find transaction in database by order_id
   5. Map Airpay status codes to our status
   6. Update transaction status, pg_txn_id, bank_ref_no
   7. If SUCCESS: Credit merchant and admin unsettled wallets (with idempotency check)
   8. Commit database changes
   9. Query merchant_callbacks table for callback URL
   10. Forward callback to merchant with proper error handling
   11. Log callback attempt in callback_logs table
   ```

3. **Status Mapping**
   ```
   Airpay Status -> Our Status
   200           -> SUCCESS
   211           -> PROCESSING
   400-405       -> FAILED
   503           -> NOT_FOUND
   Other         -> INITIATED
   ```

4. **Wallet Credits (SUCCESS only)**
   - Merchant unsettled wallet: `net_amount`
   - Admin unsettled wallet: `charge_amount`
   - Idempotency check prevents duplicate credits

5. **Merchant Callback Payload**
   ```json
   {
     "txn_id": "PAYIN_...",
     "order_id": "AP_...",
     "status": "SUCCESS",
     "amount": "100.00",
     "net_amount": "98.00",
     "charge_amount": "2.00",
     "utr": "607118043058",
     "pg_txn_id": "1820963266",
     "payment_mode": "UPI",
     "pg_partner": "Airpay",
     "timestamp": "2026-03-12T18:28:36.123456"
   }
   ```

6. **Callback Logging**
   - All callback attempts logged to `callback_logs` table
   - Includes: merchant_id, txn_id, callback_url, request_data, response_code, response_data
   - Logs both successful and failed callback attempts

## Files Modified

1. **backend/airpay_callback_routes.py**
   - Complete rewrite to match Mudrape pattern
   - Added `requests` import
   - Removed old `send_merchant_callback` function
   - Inline merchant callback forwarding with proper error handling

## Deployment

```bash
bash deploy_airpay_callback_mapping_fix.sh
```

This will:
1. Backup current callback handler
2. Deploy updated callback handler
3. Restart backend service
4. Process the already-received callback manually

## Testing

### 1. Check Already-Received Callback
The deployment script automatically processes the callback that was already received.

### 2. Test with New Payment
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_qr_generation.py
```

### 3. Verify Callback Processing
```bash
# Check callback logs
tail -f /var/www/moneyone/moneyone/backend/logs/airpay_callbacks_*.log

# Check backend logs
sudo journalctl -u moneyone-backend -f
```

### 4. Verify Database Updates
```sql
-- Check transaction status
SELECT txn_id, order_id, status, pg_txn_id, bank_ref_no, completed_at
FROM payin_transactions
WHERE pg_partner = 'Airpay'
ORDER BY created_at DESC
LIMIT 5;

-- Check wallet credits
SELECT * FROM merchant_wallet_transactions
WHERE reference_id LIKE 'PAYIN_%'
AND txn_type = 'UNSETTLED_CREDIT'
ORDER BY created_at DESC
LIMIT 5;

-- Check callback logs
SELECT * FROM callback_logs
ORDER BY created_at DESC
LIMIT 5;
```

## Expected Behavior

### When Airpay Sends Callback:

1. **Callback Received**
   ```
   ============================================================
   Airpay V4 Payin Callback Received
   ============================================================
   Callback is ENCRYPTED - decrypting...
   ✓ Extracted transaction data from 'data' field
   ```

2. **Transaction Found**
   ```
   Found Transaction: PAYIN_7679022140_..., Current Status: INITIATED
   Mapped Status: 200 -> SUCCESS
   ```

3. **Transaction Updated**
   ```
   ✓ Updated transaction status to SUCCESS
   ```

4. **Wallets Credited**
   ```
   Crediting wallets for successful payment
   ✓ Merchant unsettled wallet credited: ₹98.00
   ✓ Admin unsettled wallet credited: ₹2.00
   ```

5. **Merchant Callback Forwarded**
   ```
   Forwarding callback to merchant: https://merchant.example.com/callback
   Merchant callback response: 200
   ✓ Merchant callback sent successfully
   ```

6. **Success Response**
   ```
   ============================================================
   Callback processed successfully
   ============================================================
   ```

## Troubleshooting

### Callback Not Received
1. Check Airpay callback URL configuration
2. Verify domain is whitelisted: `api.orchpay.in`
3. Check firewall/security group rules

### Transaction Not Updated
1. Check if order_id matches in database
2. Verify pg_partner is 'Airpay'
3. Check backend logs for errors

### Wallets Not Credited
1. Verify transaction status is SUCCESS
2. Check for duplicate wallet transactions (idempotency)
3. Review wallet_service logs

### Merchant Callback Not Forwarded
1. Check merchant_callbacks table for active callback URL
2. Verify callback URL is accessible
3. Review callback_logs table for error details

## Database Schema Requirements

### merchant_callbacks table
```sql
CREATE TABLE IF NOT EXISTS merchant_callbacks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    merchant_id VARCHAR(50) NOT NULL,
    callback_url VARCHAR(500) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_merchant (merchant_id)
);
```

### callback_logs table
```sql
CREATE TABLE IF NOT EXISTS callback_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    merchant_id VARCHAR(50),
    txn_id VARCHAR(100),
    callback_url VARCHAR(500),
    request_data TEXT,
    response_code INT,
    response_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Success Criteria

✅ Callback received and decrypted successfully
✅ Transaction status updated to SUCCESS
✅ Merchant unsettled wallet credited with net_amount
✅ Admin unsettled wallet credited with charge_amount
✅ Merchant callback forwarded successfully
✅ Callback logged in callback_logs table
✅ Idempotency prevents duplicate wallet credits

## Next Steps

1. Deploy the fix using the deployment script
2. Test with a new Airpay payment
3. Monitor logs for successful callback processing
4. Verify merchant receives callback notification
5. Contact Airpay support for correct "secret" value for verify API (separate issue)
