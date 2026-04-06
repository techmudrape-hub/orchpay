# Airpay V4 Decryption Issue - CRITICAL

## Current Status: ❌ BLOCKED - Incorrect Encryption Key

## Problem Summary

Token generation API is working (200 OK with form-urlencoded), but decryption is failing because the encryption key provided is incorrect or incomplete.

## What's Working

✅ OAuth2 token request (form-urlencoded format)  
✅ API returns 200 OK  
✅ Response is encrypted (as expected)  

## What's NOT Working

❌ Decryption of the encrypted response  
❌ All decryption methods tested fail with invalid padding  

## Technical Details

### Current Configuration
- **Encryption Key**: `V8GqK8T6RC4ajHM8` (16 bytes)
- **Required Key Length**: 32 bytes for AES-256-CBC
- **Algorithm**: AES-256-CBC (per Airpay documentation)
- **IV**: First 16 characters of response (as raw string)

### Airpay's Official Decryption Method (PHP)
```php
function decrypt($response, $encryptionkey) {
    $iv = substr($response, 0, 16);
    $encryptedData = substr($response, 16);
    $decryptedData = openssl_decrypt(
        base64_decode($encryptedData), 
        'AES-256-CBC', 
        $encryptionkey, 
        OPENSSL_RAW_DATA, 
        $iv
    );
    return json_decode($decryptedData);
}
```

### Test Results

Tested all combinations:
- ❌ AES-128 with latin-1 IV (padding: 42)
- ❌ AES-256 with latin-1 IV (padding: 130)
- ❌ AES-128 with utf-8 IV (padding: 42)
- ❌ AES-256 with utf-8 IV (padding: 130)
- ❌ AES-128 with hex IV (padding: 42)
- ❌ AES-256 with hex IV (padding: 130)
- ❌ Original key length with latin-1 (padding: 42)
- ❌ Original key length with utf-8 (padding: 42)

All methods result in invalid padding, indicating the encryption key is incorrect.

## Root Cause

The encryption key `V8GqK8T6RC4ajHM8` is only 16 bytes, but AES-256-CBC requires a 32-byte key. Even when padded to 32 bytes, decryption fails, suggesting:

1. **Wrong Key**: The provided key is not the correct encryption key
2. **Key Derivation**: Airpay may be using a key derivation function (KDF) that we don't know about
3. **Different Algorithm**: Despite documentation saying AES-256-CBC, they might be using something else

## Required Actions

### URGENT: Contact Airpay Support

Email: support@airpay.co.in

**Subject**: Encryption Key Issue for Merchant ID 335854 - V4 API Integration

**Message**:
```
Hello Airpay Support Team,

We are integrating the Airpay V4 API for Merchant ID: 335854

We are successfully receiving encrypted responses from the OAuth2 endpoint, but unable to decrypt them using the provided encryption key.

Current Details:
- Merchant ID: 335854
- Client ID: c1c537
- Encryption Key Provided: V8GqK8T6RC4ajHM8 (16 bytes)
- API Endpoint: https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2

Issue:
- OAuth2 API returns 200 OK with encrypted response
- Decryption fails with all standard AES-256-CBC methods
- The provided key is only 16 bytes, but AES-256 requires 32 bytes

Request:
1. Please provide the correct 32-byte encryption key for AES-256-CBC
2. If using key derivation, please provide the exact method/algorithm
3. Please provide a sample encrypted/decrypted pair for testing
4. Confirm the exact decryption algorithm (AES-256-CBC as per documentation?)

Sample Encrypted Response:
{"merchant_id":"335854","response":"22945513ac83cc7bhCdy8lZWsfRXQKbrz4ZVr5aQTCZMs/CMs7..."}

We need this urgently to complete our integration.

Thank you,
[Your Name]
[Your Contact]
```

### Alternative: Check Environment Variables

The encryption key might be in a different environment variable. Check:

```bash
cd backend
grep -i "AIRPAY.*KEY" .env
grep -i "ENCRYPTION" .env
```

Look for:
- `AIRPAY_ENCRYPTION_KEY_V4`
- `AIRPAY_SECRET_KEY`
- `AIRPAY_API_KEY`
- Any 32-character key

### Temporary Workaround

Until Airpay provides the correct key, you cannot decrypt responses. However, you can:

1. **Test with their sandbox/demo credentials** (if they provide working ones)
2. **Request a working PHP example** from Airpay that you can test
3. **Ask for their technical integration team** to help debug

## Files Modified

- `backend/airpay_service.py` - Updated decrypt_data() method
- `backend/test_airpay_direct_decryption.py` - Direct decryption test
- `backend/test_all_airpay_decrypt_methods.py` - Comprehensive method testing

## Next Steps

1. ✅ Form-urlencoded format working
2. ✅ Token API responding correctly
3. ❌ **BLOCKED**: Get correct encryption key from Airpay
4. ⏳ Test decryption with correct key
5. ⏳ Complete integration (QR generation, payment verification, callbacks)

## Timeline

- **Discovered**: March 12, 2026
- **Status**: Waiting for Airpay support response
- **Priority**: HIGH - Blocking entire Airpay integration

## Contact Information

**Airpay Support**:
- Email: support@airpay.co.in
- Phone: [Check their website]
- Documentation: https://kraken.airpay.co.in/docs

---

**Last Updated**: March 12, 2026  
**Status**: ❌ BLOCKED - Awaiting correct encryption key from Airpay
