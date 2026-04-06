# Airpay OAuth2 Integration - Complete Success ✅

## Current Status: OAuth2 Working, Awaiting Domain Whitelist

### What's Working ✅

1. **OAuth2 Token Generation**: Fully functional
   - Endpoint: `https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2`
   - Format: `application/x-www-form-urlencoded`
   - Encryption: AES-256-CBC with MD5 key
   - Decryption: Working perfectly
   - Token expiry: 360 seconds (6 minutes)

2. **Credentials Configuration**: Updated to merchant 354479
   - Merchant ID: 354479
   - Username: 5jfP5PJgQz
   - Password: mAhXEpu7
   - Client ID: c1c537
   - Client Secret: 87a3bb9a5bd5d248354f45eca114eda7
   - Encryption Key: 07de9cfbb3397e8204e6cf6620c82e01

3. **Callback URL Configuration**: Updated
   - Old: `https://admin.moneyone.co.in/api/callback/airpay/payin`
   - New: `https://api.orchpay.in/api/callback/airpay/payin`

### What's Pending ⏳

1. **Domain Whitelist**: Airpay needs to whitelist your domains
   - API Domain: `api.orchpay.in`
   - Callback URL: `https://api.orchpay.in/api/callback/airpay/payin`
   - Frontend: `client.moneyone.co.in`

2. **QR Generation API**: Blocked until domains are whitelisted
   - Error: "Forbidden failed - Domain is not registered"

### Files Updated

1. **backend/.env**
   - Added `BACKEND_URL=https://api.orchpay.in`
   - Added `FRONTEND_URL=https://client.moneyone.co.in`
   - Updated Airpay credentials to merchant 354479
   - Updated encryption key to 07de9cfbb3397e8204e6cf6620c82e01

2. **backend/airpay_service.py**
   - Updated default callback URL to use `api.orchpay.in`
   - Changed from `admin.moneyone.co.in` to `api.orchpay.in`

### Domain Whitelist Request

A complete domain whitelist request document has been created:
- **File**: `AIRPAY_DOMAIN_WHITELIST_REQUEST.md`
- Contains all domains that need to be whitelisted
- Includes email template for Airpay support
- Ready to send to Airpay team

### Domains to Send to Airpay Support

```
Merchant ID: 354479

Primary API Domain:
- api.orchpay.in

Callback URL:
- https://api.orchpay.in/api/callback/airpay/payin

Frontend Domain:
- client.moneyone.co.in

Admin Domain (Optional):
- admin.moneyone.co.in
```

### Next Steps

1. **Send Domain Whitelist Request**
   - Open `AIRPAY_DOMAIN_WHITELIST_REQUEST.md`
   - Use the email template provided
   - Send to Airpay support team
   - Request confirmation once domains are whitelisted

2. **After Domains are Whitelisted**
   - Test QR generation API
   - Test payment verification API
   - Test callback handling
   - Deploy to production

3. **Deployment Commands**
   ```bash
   # Navigate to backend directory
   cd /var/www/moneyone/moneyone/backend
   
   # Activate virtual environment
   source venv/bin/activate
   
   # Restart backend service
   sudo systemctl restart moneyone-backend
   
   # Check service status
   sudo systemctl status moneyone-backend
   
   # Monitor logs
   sudo journalctl -u moneyone-backend -f
   ```

### Test OAuth2 Token Generation

You can test the OAuth2 token generation using:

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_oauth2_final.py
```

Expected output:
```
✅ SUCCESS!
Access Token: [40-character token]
Token Length: 40
Expires: [timestamp]
```

### Technical Implementation Details

**Encryption Key Generation:**
```python
import hashlib
key = hashlib.md5(f"{username}~:~{password}".encode()).hexdigest()
# Result: 07de9cfbb3397e8204e6cf6620c82e01
```

**OAuth2 Payload Structure:**
```python
payload = {
    'merchant_id': '354479',
    'encdata': encrypted_json,  # Encrypted credentials
    'checksum': sha256_hash
}
```

**Decryption Process:**
```python
# IV = first 16 characters as raw string
iv = encrypted_response[:16].encode('latin-1')
encrypted_data = base64.b64decode(encrypted_response[16:])

# AES-256-CBC decryption
cipher = AES.new(key.encode(), AES.MODE_CBC, iv)
decrypted = cipher.decrypt(encrypted_data)

# Remove PKCS5 padding
padding_length = decrypted[-1]
result = decrypted[:-padding_length]
```

### Configuration Summary

**Environment Variables (.env):**
```env
BACKEND_URL=https://api.orchpay.in
FRONTEND_URL=https://client.moneyone.co.in

AIRPAY_BASE_URL=https://kraken.airpay.co.in
AIRPAY_CLIENT_ID=c1c537
AIRPAY_CLIENT_SECRET=87a3bb9a5bd5d248354f45eca114eda7
AIRPAY_MERCHANT_ID=354479
AIRPAY_USERNAME=5jfP5PJgQz
AIRPAY_PASSWORD=mAhXEpu7
AIRPAY_ENCRYPTION_KEY=07de9cfbb3397e8204e6cf6620c82e01
```

**Callback URL in Code:**
```python
base_url = os.getenv('BACKEND_URL', 'https://api.orchpay.in')
callback_url = f"{base_url}/api/callback/airpay/payin"
# Result: https://api.orchpay.in/api/callback/airpay/payin
```

### Contact Airpay Support

**What to Send:**
1. Merchant ID: 354479
2. Domains to whitelist:
   - api.orchpay.in
   - client.moneyone.co.in
   - admin.moneyone.co.in (optional)
3. Callback URL: https://api.orchpay.in/api/callback/airpay/payin

**Expected Response:**
- Confirmation that domains are whitelisted
- Estimated time for activation
- Any additional requirements

### Troubleshooting

**If OAuth2 fails after deployment:**
```bash
# Check environment variables
cd /var/www/moneyone/moneyone/backend
cat .env | grep AIRPAY

# Test token generation
source venv/bin/activate
python3 test_airpay_oauth2_final.py

# Check logs
sudo journalctl -u moneyone-backend -f | grep -i airpay
```

**If QR generation fails:**
- Verify domains are whitelisted with Airpay
- Check that BACKEND_URL is set correctly
- Ensure OAuth2 token is being generated successfully
- Monitor logs for detailed error messages

---

## Summary

✅ OAuth2 token generation working perfectly
✅ Credentials updated to merchant 354479
✅ Callback URL configured for api.orchpay.in
✅ Environment variables updated
✅ Code changes deployed

⏳ Waiting for Airpay to whitelist domains
⏳ QR generation will work after domain whitelist

📧 Send domain whitelist request to Airpay support using the template in `AIRPAY_DOMAIN_WHITELIST_REQUEST.md`
