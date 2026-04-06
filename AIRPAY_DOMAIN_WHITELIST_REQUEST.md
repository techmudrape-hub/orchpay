# Airpay Domain Whitelist Request

## Merchant Information
- **Merchant ID**: 354479
- **Client ID**: c1c537
- **Username**: 5jfP5PJgQz

## Domains to be Whitelisted

Please whitelist the following domains for our Airpay V4 API integration:

### 1. API Domain (Primary) - CRITICAL
```
api.orchpay.in
```
This is our main API server that will make requests to Airpay V4 API endpoints.
**Status**: Whitelisted ✅

### 2. Merchant Domain (mer_dom parameter) - CRITICAL
```
client.moneyone.co.in
```
This is sent as the `mer_dom` parameter (base64 encoded) in the generateOrder API request.
**Base64 Encoded Value**: `aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=`
**Status**: NOT REGISTERED ❌ (This is causing the current error)

### 3. Callback URL - CRITICAL
```
https://api.orchpay.in/api/callback/airpay/payin
```
This is the callback endpoint where Airpay should send payment status notifications.
**Status**: Whitelisted ✅

### 4. Admin Domain (Optional)
```
admin.moneyone.co.in
```
This is our admin panel domain (optional, for administrative access).

## Current Issue - UPDATED

We are successfully generating OAuth2 access tokens but receiving the following error when calling the Generate QR API:

```json
{
  "details": {
    "data": [],
    "message": "Authentication Operation Failed - Domain id not registered.",
    "response_code": "U04",
    "status": "fail",
    "status_code": "400"
  },
  "message": "Authentication Operation Failed - Domain id not registered.",
  "success": false
}
```

**Root Cause**: The `mer_dom` parameter (merchant domain) is not registered in Airpay's system.

**What's Working**:
- ✅ OAuth2 token generation
- ✅ API domain (api.orchpay.in) is whitelisted
- ✅ Callback URL is whitelisted

**What's NOT Working**:
- ❌ Merchant domain (client.moneyone.co.in) is NOT registered
- ❌ This domain is sent as `mer_dom` parameter in generateOrder API
- ❌ Airpay is rejecting the request because this domain is not in their whitelist

## APIs We Need Access To

1. **OAuth2 Token Generation**: `/airpay/pay/v4/api/oauth2` ✅ (Working)
2. **Generate QR Code**: `/airpay/pay/v4/api/generateOrder` ❌ (Domain not registered)
3. **Payment Verification**: `/airpay/pay/v4/api/verifyPayment` (Pending)
4. **Callback Handler**: Receive callbacks at our endpoint (Pending)

## Request Format

Please configure the following in your system:

```
Merchant ID: 354479

1. API Domain (for API calls):
   api.orchpay.in
   Status: Already whitelisted ✅

2. Merchant Domain (mer_dom parameter):
   client.moneyone.co.in
   Base64 Encoded: aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=
   Status: NEEDS TO BE WHITELISTED ❌

3. Callback URL:
   https://api.orchpay.in/api/callback/airpay/payin
   Status: Already whitelisted ✅
```

**IMPORTANT**: The error "Domain id not registered" specifically refers to the `mer_dom` parameter. Please register `client.moneyone.co.in` as the merchant domain for our account.

## Contact Information

Please confirm once the domains are whitelisted so we can proceed with testing the complete payment flow.

---

## Email Template for Airpay Support

**Subject**: URGENT: Merchant Domain Registration Required for Merchant 354479

Dear Airpay Support Team,

We are integrating Airpay V4 API for our payment gateway platform. We have successfully implemented OAuth2 token generation and you have already whitelisted our API domain and callback URL. However, we are receiving an error when calling the generateOrder API.

**Merchant Details:**
- Merchant ID: 354479
- Client ID: c1c537

**Current Error:**
```
Authentication Operation Failed - Domain id not registered.
Response Code: U04
```

**Domain Status:**
1. ✅ API Domain: `api.orchpay.in` (Already whitelisted - working)
2. ✅ Callback URL: `https://api.orchpay.in/api/callback/airpay/payin` (Already whitelisted)
3. ❌ Merchant Domain: `client.moneyone.co.in` (NOT REGISTERED - causing error)

**Issue:**
The `mer_dom` parameter in our generateOrder API request contains `client.moneyone.co.in` (base64 encoded as `aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=`). This domain needs to be registered as our merchant domain in your system.

**Request:**
Please register `client.moneyone.co.in` as the merchant domain (mer_dom) for Merchant ID 354479.

**Current Status:**
- OAuth2 token generation: ✅ Working
- API domain whitelisted: ✅ Working
- Callback URL whitelisted: ✅ Working
- Generate QR API: ❌ Error: "Domain id not registered" (waiting for merchant domain registration)

We are ready to proceed with testing once the merchant domain is registered.

Thank you for your prompt assistance.

Best regards,
[Your Name]
[Your Contact Information]

---

## Technical Details (For Reference)

### Current Configuration
- Base URL: `https://kraken.airpay.co.in`
- OAuth2 Endpoint: `/airpay/pay/v4/api/oauth2` (Working)
- Generate Order Endpoint: `/airpay/pay/v4/api/generateOrder` (Blocked)
- Encryption: AES-256-CBC with MD5 key generation
- Format: application/x-www-form-urlencoded

### Test Results
```
✅ OAuth2 Token Generation: SUCCESS
   - Access Token: Generated successfully
   - Token Expiry: 360 seconds
   - Encryption/Decryption: Working perfectly

❌ QR Generation: FAILED
   - Error: "Forbidden failed - Domain is not registered"
   - Reason: Domain whitelist not configured
```

### Next Steps After Whitelisting
1. Test QR generation API
2. Test payment verification API
3. Test callback handling
4. Deploy to production
5. Monitor transactions

---

## Summary

**Domains Required:**
- `api.orchpay.in` (API server)
- `client.moneyone.co.in` (Frontend)
- `admin.moneyone.co.in` (Admin panel - optional)

**Callback URL:**
- `https://api.orchpay.in/api/callback/airpay/payin`

**Merchant ID:** 354479

Please send this information to Airpay support team to get your domains whitelisted.
