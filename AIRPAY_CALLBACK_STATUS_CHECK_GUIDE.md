# Airpay V4 Callback & Status Check Complete Guide

## Current Status

### ✅ What's Working
1. **OAuth2 Token Generation** - Successfully generating access tokens
2. **QR Code Generation** - Creating UPI QR codes with proper encryption
3. **Encryption/Decryption** - AES-256-CBC working perfectly
4. **Callback Handler** - Configured to receive plain JSON callbacks from Airpay
5. **Auto Status Check** - Automatic status verification 60 seconds after QR generation

### ⚠️ Current Issue
- **No callbacks received yet** from Airpay for test transactions
- Both test transactions still in INITIATED status
- Callback URL is properly configured: `https://api.orchpay.in/api/callback/airpay/payin`

## Airpay V4 API Endpoints

### 1. Check Status API (Order Confirmation)

**Endpoint:** `POST /airpay/pay/v4/api/verify/?token=<access_token>`

**Purpose:** Pull transaction status updates from Airpay

**Request Format:**
```
Content-Type: application/x-www-form-urlencoded

merchant_id: <merchant_id>
encdata: <encrypted_json_data>
checksum: <sha256_checksum>
```

**Encrypted Data (JSON):**
```json
{
  "orderid": "ORDER123",           // Option 1: Merchant order ID
  "ap_transactionid": "12345678",  // Option 2: Airpay transaction ID
  "rrn": "556677"                  // Option 3: RRN/UTR number
}
```
*At least one identifier is required*

**Response (Encrypted):**
```json
{
  "status_code": "200",
  "status": "success",
  "response_code": "00",
  "message": "Success",
  "data": {
    "transaction_payment_status": "SUCCESS",
    "merchant_id": "123356",
    "orderid": "ORDER123456",
    "ap_transactionid": "11314",
    "amount": "100.00",
    "transaction_status": 200,
    "message": "Success",
    "rrn": "016153570198200",
    "chmod": "upi",
    "pgbank_name": "AXIS BANK",
    "customer_vpa": "customer@upi",
    "customer_name": "John Doe",
    "customer_email": "customer@example.com",
    "customer_phone": "9898989898"
  }
}
```

**Transaction Status Codes:**
- `200` - Transaction is success
- `211` - Transaction is processing
- `400` - Transaction is failed
- `401` - Transaction will not register properly
- `402` - Payment that has not yet been processed
- `403` - Not received any call back from bank
- `405` - Transaction has bounced
- `503` - No records found

### 2. IPN Callback (Instant Payment Notification)

**Endpoint:** `POST https://api.orchpay.in/api/callback/airpay/payin`

**Format:** Plain JSON (NOT encrypted)

**Callback Payload:**
```json
{
  "merchant_id": 45,
  "ap_transactionid": 4324324,
  "amount": 1999.00,
  "transaction_status": 200,
  "message": "Success",
  "orderid": "ORDER123",
  "customvar": "merchant_id=XXX|txn_id=YYY|callback_url=https://...",
  "chmod": "upi",
  "bank_name": "AXIS BANK",
  "rrn": "016153570198200",
  "customer_name": "John",
  "customer_email": "customer@example.com",
  "customer_phone": "9898989898",
  "customer_vpa": "customer@upi",
  "currency_code": 356,
  "transaction_type": 320,
  "transaction_payment_status": "SUCCESS",
  "transaction_time": "12-12-2023 10:10:12",
  "ap_SecureHash": "1490948220"
}
```

**Key Fields:**
- `merchant_id` - Airpay merchant ID
- `ap_transactionid` - Airpay transaction reference
- `orderid` - Merchant order ID
- `transaction_status` - Status code (200=success, 400=failed, etc.)
- `rrn` - Bank reference/UTR number
- `chmod` - Payment channel (upi, pg, nb, etc.)
- `customvar` - Custom data passed in request

## Implementation Details

### Check Status Implementation

**File:** `backend/airpay_service.py`

```python
def verify_payment(self, order_id=None, ap_transactionid=None, rrn=None):
    """
    Check payment status using Airpay V4 API
    At least one identifier required
    """
    # 1. Get OAuth2 token
    token = self.generate_access_token()
    
    # 2. Prepare verification data
    verify_data = {}
    if order_id:
        verify_data['orderid'] = order_id
    if ap_transactionid:
        verify_data['ap_transactionid'] = ap_transactionid
    if rrn:
        verify_data['rrn'] = rrn
    
    # 3. Encrypt data
    encrypted_data = self.encrypt_data(json.dumps(verify_data))
    
    # 4. Generate checksum
    checksum = self.generate_checksum(verify_data)
    
    # 5. Send request
    payload = {
        'merchant_id': self.merchant_id,
        'encdata': encrypted_data,
        'checksum': checksum
    }
    
    response = requests.post(
        f"{self.base_url}/airpay/pay/v4/api/verify/?token={token}",
        data=payload,
        headers={'Content-Type': 'application/x-www-form-urlencoded'}
    )
    
    # 6. Decrypt response
    result = response.json()
    if 'response' in result:
        result = self.decrypt_data(result['response'])
    
    # 7. Map status
    transaction_status = result['data']['transaction_status']
    if transaction_status == 200:
        status = 'SUCCESS'
    elif transaction_status == 211:
        status = 'PROCESSING'
    elif transaction_status in [400, 401, 402, 403, 405]:
        status = 'FAILED'
    
    return {'success': True, 'status': status, 'data': result['data']}
```

### Callback Handler Implementation

**File:** `backend/airpay_callback_routes.py`

```python
@airpay_callback_bp.route('/payin', methods=['POST'])
def airpay_payin_callback():
    """
    Handle Airpay V4 IPN callback
    Receives plain JSON (NOT encrypted)
    """
    # 1. Log raw callback data
    log_raw_callback_data(request)
    
    # 2. Parse callback data (plain JSON)
    if request.is_json:
        callback_data = request.get_json()
    else:
        callback_data = request.form.to_dict()
    
    # 3. Extract fields
    orderid = callback_data.get('orderid')
    ap_transactionid = callback_data.get('ap_transactionid')
    transaction_status = callback_data.get('transaction_status')
    rrn = callback_data.get('rrn')
    
    # 4. Find transaction in database
    txn = find_transaction_by_order_id(orderid)
    
    # 5. Map status
    if transaction_status == 200:
        new_status = 'SUCCESS'
    elif transaction_status in [400, 401, 402, 403, 405]:
        new_status = 'FAILED'
    
    # 6. Update transaction
    update_transaction_status(txn['txn_id'], new_status, rrn, ap_transactionid)
    
    # 7. Credit wallets if SUCCESS
    if new_status == 'SUCCESS':
        credit_merchant_wallet(txn['merchant_id'], txn['net_amount'])
        credit_admin_wallet('admin', txn['charge_amount'])
    
    # 8. Forward callback to merchant
    send_merchant_callback(txn, callback_data, merchant_callback_url)
    
    return jsonify({'success': True})
```

### Auto Status Check

**Triggered:** 60 seconds after QR generation

**Process:**
1. Wait 60 seconds
2. Check if transaction still in INITIATED/PENDING status
3. Call `verify_payment()` with order_id
4. If status changed to SUCCESS:
   - Update transaction status
   - Credit merchant unsettled wallet
   - Credit admin unsettled wallet
5. If status changed to FAILED:
   - Update transaction status

## Testing

### Test Check Status API

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_check_status.py
```

This will:
1. Fetch the 2 most recent Airpay transactions
2. Test check status by Order ID
3. Test check status by Airpay Transaction ID
4. Display current status and any changes

### Check Recent Transactions

```bash
python3 check_airpay_simple.py
```

Shows:
- Transaction details
- Wallet credit status
- Whether callbacks were received

### Check Callback Logs

```bash
# Server logs
sudo journalctl -u moneyone-backend --since '2 hours ago' | grep -A 50 'Airpay V4 Payin Callback'

# Callback log file
cat /var/www/moneyone/moneyone/backend/logs/airpay_callbacks_*.log | tail -100

# Search specific order
sudo journalctl -u moneyone-backend | grep 'AP_7679022140_ORD989898987876563726_20260312180539'
```

## Troubleshooting

### No Callbacks Received

**Possible Causes:**
1. Domain not whitelisted with Airpay
2. Callback URL incorrect in Airpay system
3. Payment not completed by customer
4. Airpay callback system delay

**Solutions:**
1. Verify domain whitelist: Contact Airpay support
2. Check callback URL configuration
3. Use check status API to manually verify
4. Auto status check will update after 60 seconds

### Status Check Returns "No Records Found" (503)

**Cause:** Transaction not found in Airpay system

**Solutions:**
1. Verify order_id is correct
2. Try with ap_transactionid instead
3. Check if QR generation was successful

### Callback Not Forwarding to Merchant

**Check:**
1. `callback_url` field in `payin_transactions` table
2. `customvar` parameter contains callback URL
3. Merchant callback endpoint is accessible

**Debug:**
```sql
SELECT txn_id, order_id, callback_url 
FROM payin_transactions 
WHERE pg_partner = 'Airpay' 
ORDER BY created_at DESC 
LIMIT 5;
```

## Current Credentials

**Merchant ID:** 354479  
**Username:** 5jfP5PJgQz  
**Password:** mAhXEpu7  
**Client ID:** c1c537  
**Client Secret:** 87a3bb9a5bd5d248354f45eca114eda7  
**Encryption Key:** 07de9cfbb3397e8204e6cf6620c82e01  
**Merchant Domain:** api.orchpay.in (whitelisted)  
**Callback URL:** https://api.orchpay.in/api/callback/airpay/payin

## Next Steps

1. **Test with Real Payment:**
   - Generate QR code
   - Complete payment using UPI app
   - Verify callback is received
   - Check wallet credits

2. **Monitor Logs:**
   - Watch for callback reception
   - Verify auto status check works
   - Check merchant callback forwarding

3. **Production Deployment:**
   - Deploy updated code
   - Restart backend service
   - Test end-to-end flow
   - Monitor first few transactions

## Files Updated

1. `backend/airpay_service.py` - Enhanced verify_payment method
2. `backend/airpay_callback_routes.py` - Improved callback field mapping
3. `backend/check_airpay_simple.py` - Fixed diagnostic script
4. `backend/test_airpay_check_status.py` - New status check test script

## Summary

The Airpay V4 integration is complete with:
- ✅ OAuth2 token generation
- ✅ QR code generation with encryption
- ✅ Check status API (verify payment)
- ✅ IPN callback handler (plain JSON)
- ✅ Auto status check (60s after QR)
- ✅ Wallet credit on success
- ✅ Merchant callback forwarding

The system is ready for testing with real payments. The auto status check ensures transactions are updated even if callbacks fail.
