# Airpay V4 API - Form URL-Encoded Fix

## Issue Discovered

The Airpay V4 OAuth2 API was returning **403 Forbidden** when sending requests in JSON format, but **200 OK** when using form URL-encoded format.

## Root Cause

Airpay's OAuth2 endpoint expects `application/x-www-form-urlencoded` format, NOT `application/json`.

## Test Results

```
❌ FAIL - JSON Format (403 Forbidden)
✅ PASS - Form URL-encoded (200 OK with encrypted response)
❌ FAIL - JSON (string merchant_id) (403 Forbidden)
❌ FAIL - Different Endpoint (404 Not Found)
```

## Solution Applied

Updated `backend/airpay_service.py` in the `generate_access_token()` method:

### Before (JSON format):
```python
response = requests.post(
    url,
    json=payload,
    headers={'Content-Type': 'application/json'},
    timeout=30
)
```

### After (Form URL-encoded):
```python
response = requests.post(
    url,
    data=payload,  # Changed from json= to data=
    headers={'Content-Type': 'application/x-www-form-urlencoded'},
    timeout=30
)
```

## Additional Changes

1. **Merchant ID format**: Keep as string instead of converting to int
2. **Response decryption**: Added decryption logic for encrypted token response
3. **Token caching**: Maintained existing caching mechanism

## Testing

### Test 1: Token Generation
```bash
cd backend
python3 test_airpay_token_complete.py
```

Expected output:
```
✅ SUCCESS!
Access Token: 00f9a570f917aa8a5df6ae532b...
Token Length: 40
🎉 Airpay V4 integration is ready!
```

### Test 2: Complete Integration
```bash
cd backend
python3 test_airpay_v4_complete.py
```

Expected output:
```
✅ PASS - OAuth2 Token Generation
✅ PASS - Encryption/Decryption
✅ PASS - Generate QR Code
✅ PASS - Verify Payment
```

## Files Modified

1. **backend/airpay_service.py**
   - Updated `generate_access_token()` method
   - Changed request format from JSON to form URL-encoded
   - Added response decryption logic

## Response Format

The API returns an encrypted response:

```json
{
  "merchant_id": "335854",
  "response": "e83fad2fa3b880848f8QfRRD6PH+w9YXXXHi4x/cPSt75vjpBcY6C7rUq8Zk2ujXWbRdzd8OaIy3Wlpsgodrh7Y/Ofu+msvqnStxLSsi9YZXuhfqjGfASDgyr+VKOXXv2MIm+1KnkrSPh/EtzMrS6/I9a8YtC7qz2ip82w=="
}
```

After decryption:
```json
{
  "status_code": "200",
  "response_code": "00",
  "status": "success",
  "message": "Success",
  "data": {
    "access_token": "00f9a570f917aa8a5df6ae532b5b773f71a00a1a",
    "expires_in": 300,
    "scope": null
  }
}
```

## Deployment

```bash
# Restart backend to apply changes
sudo systemctl restart backend

# Verify service is running
sudo systemctl status backend

# Test token generation
cd /var/www/moneyone/moneyone/backend
python3 test_airpay_token_complete.py
```

## Next Steps

1. ✅ Token generation working
2. ⏳ Test QR code generation
3. ⏳ Test payment verification
4. ⏳ Test callback handling
5. ⏳ Production deployment

## Important Notes

- **No IP whitelisting needed**: The form URL-encoded format works without IP whitelisting
- **Response is encrypted**: All responses need to be decrypted using the encryption key
- **Token expires in 5 minutes**: Implement token caching (already done)
- **Use form data for all V4 endpoints**: Other endpoints may also require form URL-encoded format

## Troubleshooting

### If token generation still fails:

1. **Check credentials**:
   ```bash
   grep AIRPAY_ backend/.env
   ```

2. **Check backend logs**:
   ```bash
   tail -f /var/log/backend.log | grep -i airpay
   ```

3. **Test manually**:
   ```bash
   cd backend
   python3 diagnose_airpay_token.py
   ```

4. **Verify encryption key**:
   ```bash
   python3 -c "from config import Config; print(len(Config.AIRPAY_ENCRYPTION_KEY))"
   # Should output: 32 (or close to it)
   ```

## Success Criteria

✅ Token generation returns 200 OK  
✅ Response is successfully decrypted  
✅ Access token is extracted  
✅ Token caching works  
✅ Token expiry is tracked  

---

**Status**: ✅ FIXED  
**Date**: March 12, 2026  
**Version**: 1.0  
