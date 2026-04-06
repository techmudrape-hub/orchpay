# Airpay V4 Integration - Decryption SUCCESS ✅

## Current Status: Decryption Working, Checksum Issue Remaining

### What's Working ✅

1. **Encryption Key Generation** - WORKING
   - Key = MD5(username~:~password)
   - Generated key: `bb0f9631717c57a6b7fcb2e2e4a30205`

2. **OAuth2 Request** - WORKING
   - Form URL-encoded format working (not JSON)
   - Returns 200 OK with encrypted response

3. **Decryption** - WORKING ✅
   - IV extraction (first 16 characters as raw string)
   - IV encoding with latin-1
   - AES-256-CBC decryption
   - PKCS5 padding removal
   - JSON parsing

### What's NOT Working ❌

**Checksum Validation** - The checksum generation algorithm needs refinement

Current checksum string: `c1c53787a3bb9a5bd5d248354f45eca114eda7client_credentials3358542026-03-12`

This concatenates all values without separators, which might be incorrect.

## Technical Implementation

### 1. Encryption Key
```python
key_string = f"{username}~:~{password}"
encryption_key = hashlib.md5(key_string.encode('utf-8')).hexdigest()
# Result: bb0f9631717c57a6b7fcb2e2e4a30205 (32 characters)
```

### 2. Decryption Method
```python
def decrypt_data(encrypted_response):
    # Extract IV (first 16 chars as raw string)
    iv_string = encrypted_response[:16]
    encrypted_data_b64 = encrypted_response[16:]
    
    # Convert IV to bytes (latin-1 encoding)
    iv_bytes = iv_string.encode('latin-1')
    
    # Decode base64
    encrypted_data = base64.b64decode(encrypted_data_b64)
    
    # Prepare 32-byte key
    key_bytes = encryption_key.encode('latin-1')
    
    # Decrypt with AES-256-CBC
    cipher = AES.new(key_bytes, AES.MODE_CBC, iv_bytes)
    decrypted_data = cipher.decrypt(encrypted_data)
    
    # Remove padding
    unpadded_data = unpad(decrypted_data, AES.block_size)
    
    # Parse JSON
    return json.loads(unpadded_data.decode('utf-8'))
```

### 3. Checksum Generation (Needs Fix)

According to Airpay documentation:
1. Collect all key-value pairs
2. Arrange in alphabetical order by keys
3. Combine values into a single string
4. Append current date in YYYY-MM-DD format
5. Use SHA-256 to compute hash

**Current Implementation:**
```python
def generate_checksum(data_dict):
    sorted_keys = sorted(data_dict.keys())
    checksum_data = ''
    for key in sorted_keys:
        checksum_data += str(data_dict[key])
    current_date = datetime.now().strftime('%Y-%m-% d')
    checksum_data += current_date
    return hashlib.sha256(checksum_data.encode('utf-8')).hexdigest()
```

**Possible Issues:**
- Values might need separators between them
- Date format might need to be different
- Specific fields might need to be excluded from checksum
- Order of concatenation might be different

## Next Steps

### Option 1: Contact Airpay Support (RECOMMENDED)
Email: support@airpay.co.in

**Request:**
```
Subject: Checksum Generation for OAuth2 API - Merchant ID 335854

Hello Airpay Support,

We have successfully implemented:
✅ Encryption key generation (MD5 of username~:~password)
✅ Response decryption (AES-256-CBC)
✅ Form URL-encoded requests

However, we're getting "Invalid Checksum" error (response_code: 903).

Could you please provide:
1. Exact checksum generation algorithm for OAuth2 endpoint
2. Sample request with correct checksum
3. Which fields should be included in checksum calculation?
4. Should values be separated? If yes, with what character?

Our current implementation:
- Sorted keys alphabetically
- Concatenated values
- Appended date (YYYY-MM-DD)
- SHA-256 hash

Merchant Details:
- Merchant ID: 335854
- Client ID: c1c537

Thank you!
```

### Option 2: Try Alternative Checksum Methods

Test different variations:
1. Include/exclude certain fields
2. Different separators (pipe |, tilde ~, none)
3. Different date formats
4. Include keys in checksum, not just values

### Option 3: Check if OAuth2 Needs Checksum

Some OAuth2 implementations don't require checksum for token generation. Try:
- Remove checksum from OAuth2 request
- Only use checksum for other API calls (QR generation, verification)

## Files Modified

1. **backend/airpay_service.py**
   - ✅ Updated `__init__` to generate encryption key from username/password
   - ✅ Updated `decrypt_data()` with correct IV handling
   - ✅ Added `generate_checksum()` method
   - ⚠️ Updated `generate_access_token()` to include checksum (needs refinement)

2. **backend/.env**
   - ✅ Updated AIRPAY_ENCRYPTION_KEY to correct value

## Test Results

```bash
Encryption Key: bb0f9631717c57a6b7fcb2e2e4a30205 ✅
Token Request: 200 OK ✅
Response Decryption: SUCCESS ✅
Checksum Validation: FAILED ❌
```

## Credentials Summary

```
Merchant ID: 335854
Username: CKFzeZGut2
Password: WRx4M373
Client ID: c1c537
Client Secret: 87a3bb9a5bd5d248354f45eca114eda7
Encryption Key: bb0f9631717c57a6b7fcb2e2e4a30205 (generated)
```

## Important Notes

1. **Decryption is 100% working** - This is a major milestone!
2. **Only checksum needs to be fixed** - Contact Airpay for exact algorithm
3. **All infrastructure is ready** - Once checksum is fixed, integration is complete
4. **OAuth2 might not need checksum** - Try without it for token endpoint

---

**Date**: March 12, 2026  
**Status**: 🟡 Decryption Working, Checksum Pending  
**Next Action**: Contact Airpay support for checksum algorithm
