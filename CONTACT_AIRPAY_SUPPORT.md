# Contact Airpay Support - OAuth2 Issue

## Current Status

✅ Encryption/Decryption: WORKING
✅ Checksum Generation: WORKING (no more "Invalid Checksum" error)
✅ API Communication: WORKING (200 OK response)
❌ Credentials Validation: FAILING ("Invalid client id or secret")

## What's Working

1. Form URL-encoded requests
2. AES-256-CBC encryption with correct IV
3. Response decryption
4. Checksum algorithm (SHA-256)
5. All API endpoints responding correctly

## The Problem

Despite using the exact credentials from the OAuth2 management dashboard, we're getting:

```json
{
  "status_code": "200",
  "response_code": "00",
  "status": "success",
  "message": "Success",
  "data": {
    "success": false,
    "msg": "Invalid client id or secret"
  }
}
```

## Credentials Being Used

```
Merchant ID: 335854
Client ID: c1c537
Client Secret: 87a3bb9a5bd5d248354f45eca114eda7
Username: CKFzeZGut2
Password: WRx4M373
```

These match exactly what's shown in the OAuth2 management dashboard.

## Request Details

**Endpoint:** POST https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2

**Payload:**
```
merchant_id=335854
encdata=[encrypted JSON of credentials]
checksum=[SHA-256 hash]
```

**Encrypted Data Contains:**
```json
{
  "client_id": "c1c537",
  "client_secret": "87a3bb9a5bd5d248354f45eca114eda7",
  "merchant_id": "335854",
  "grant_type": "client_credentials"
}
```

## Questions for Airpay Support

1. Are the credentials shown in the dashboard the correct ones for OAuth2 API?
2. Is there a different set of credentials for API access vs dashboard access?
3. Do we need to activate/enable the OAuth2 credentials separately?
4. Is there a specific format or encoding required for client_id/client_secret?
5. Are there any IP whitelist requirements?

## Contact Information

**Email:** support@airpay.co.in

**Subject:** OAuth2 API - Invalid Credentials Error (Merchant ID: 335854)

**Email Template:**

```
Dear Airpay Support Team,

We are integrating Airpay V4 API for Merchant ID 335854 and have successfully implemented:
✅ Encryption/Decryption (AES-256-CBC)
✅ Checksum generation (SHA-256)
✅ Form URL-encoded requests
✅ Response parsing

However, we're receiving "Invalid client id or secret" error when calling the OAuth2 endpoint, despite using the exact credentials from the OAuth2 management dashboard:

Client ID: c1c537
Client Secret: 87a3bb9a5bd5d248354f45eca114eda7
Merchant ID: 335854

The API is responding correctly (200 OK), decryption is working, and checksum is being accepted. This suggests our implementation is correct, but the credentials might need activation or there's a different set of credentials for API access.

Could you please:
1. Verify if these credentials are active and correct for OAuth2 API
2. Check if there are any additional steps needed to activate API access
3. Confirm if there are IP whitelist requirements
4. Provide a working example or test credentials if possible

Thank you for your assistance.

Best regards,
MoneyOne Development Team
```

## Alternative: Test with Sandbox/UAT Credentials

If Airpay has a sandbox environment, request test credentials to verify the implementation works before using production credentials.

## Next Steps

1. Contact Airpay support using the email template above
2. Request verification of credentials
3. Ask for test/sandbox credentials if available
4. Request API documentation update if there are missing steps

---

**Date:** March 12, 2026
**Status:** Awaiting Airpay Support Response
