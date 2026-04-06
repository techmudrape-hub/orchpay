# Airpay Private Key Fix - Check Status API

## Issue Identified

The check status (verify) API was failing with two errors:
1. **"Invalid Order Id"** - When querying by orderid
2. **"Invalid Private Key"** - When querying by ap_transactionid

## Root Cause

According to the Airpay V4 API documentation, the verify/check status endpoint requires a `privatekey` parameter in addition to `merchant_id`, `encdata`, and `checksum`.

### PHP Documentation Reference:
```php
$privatekey = hash('sha256', $secret.'@'.$username.':|:'.$password);

$payload = [
    'merchant_id' => $merchant_id,
    'encdata' => $encdata,
    'checksum' => $checksum,
    'privatekey' => $privatekey  // THIS WAS MISSING!
];
```

## Solution Implemented

### 1. Added AIRPAY_SECRET to Configuration

**File:** `backend/config.py`
```python
AIRPAY_SECRET = os.getenv('AIRPAY_SECRET', os.getenv('AIRPAY_CLIENT_SECRET', ''))
```

By default, uses `client_secret` as the secret value (common practice).

### 2. Generate Private Key in Service

**File:** `backend/airpay_service.py`

Added privatekey generation in `__init__`:
```python
# Generate privatekey for verify API
# privatekey = SHA256(secret@username:|:password)
privatekey_string = f"{self.secret}@{self.username}:|:{self.password}"
self.privatekey = hashlib.sha256(privatekey_string.encode('utf-8')).hexdigest()
```

### 3. Include Private Key in Verify Request

Updated `verify_payment()` method:
```python
payload = {
    'merchant_id': self.merchant_id,
    'encdata': encrypted_data,
    'checksum': checksum,
    'privatekey': self.privatekey  # Now included!
}
```

## Private Key Formula

```
privatekey = SHA256(secret@username:|:password)
```

**Example:**
- Secret: `87a3bb9a5bd5d248354f45eca114eda7`
- Username: `5jfP5PJgQz`
- Password: `mAhXEpu7`
- String: `87a3bb9a5bd5d248354f45eca114eda7@5jfP5PJgQz:|:mAhXEpu7`
- Private Key: `SHA256(above_string)`

## Testing

### Test Private Key Generation

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_privatekey.py
```

This will:
1. Display credentials
2. Show privatekey generation process
3. Test verify API with the privatekey
4. Confirm if it works

### Test Check Status API

```bash
python3 test_airpay_check_status.py
```

Should now work without "Invalid Private Key" errors.

## Files Modified

1. `backend/config.py` - Added AIRPAY_SECRET configuration
2. `backend/airpay_service.py` - Added privatekey generation and usage
3. `backend/test_airpay_privatekey.py` - New test script

## Deployment

```bash
cd /var/www/moneyone/moneyone/backend
sudo systemctl restart moneyone-backend
```

## Expected Results

After this fix:
- ✅ Check status by Order ID should work
- ✅ Check status by Airpay Transaction ID should work
- ✅ Check status by RRN should work
- ✅ Auto status check (60s after QR) should work
- ✅ Transactions should update from INITIATED to SUCCESS/FAILED

## Important Notes

1. **Secret Value**: Currently using `client_secret` as the secret. If Airpay provided a different secret value, update `.env`:
   ```
   AIRPAY_SECRET=<actual_secret_from_airpay>
   ```

2. **Verify API Parameters**: The verify API accepts at least one of:
   - `orderid` - Merchant order ID
   - `ap_transactionid` - Airpay transaction ID
   - `rrn` - Bank reference number

3. **Response Format**: Verify API response is encrypted and must be decrypted (already implemented).

## Next Steps

1. Test the privatekey fix
2. Verify check status API works
3. Test with real payment to confirm callback + status check flow
4. Monitor auto status check (60s after QR generation)

## Summary

The missing `privatekey` parameter was causing all verify/check status API calls to fail. This parameter is generated using SHA256 hash of a specific string format and must be included in every verify API request. With this fix, the check status API should now work correctly, enabling automatic transaction status updates.
