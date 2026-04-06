# Airpay V4 API Integration - Complete Configuration Guide

## Overview

This guide provides complete instructions for integrating Airpay V4 API with your MoneyOne payment gateway system. The integration includes:

- **OAuth2 Authentication**: Token-based API access
- **AES Encryption/Decryption**: Secure data transmission
- **QR Code Generation**: UPI payment QR codes
- **Payment Verification**: Real-time status checks
- **Callback Handling**: Instant Payment Notifications (IPN)

## Prerequisites

1. Airpay merchant account credentials
2. Python 3.8+ with required packages
3. MySQL database
4. SSL certificate for callback URL

## Step 1: Environment Configuration

Add the following to your `backend/.env` file:

```bash
# Airpay V4 Configuration
AIRPAY_BASE_URL=https://kraken.airpay.co.in
AIRPAY_CLIENT_ID=your_client_id
AIRPAY_CLIENT_SECRET=your_client_secret
AIRPAY_MERCHANT_ID=your_merchant_id
AIRPAY_USERNAME=your_username
AIRPAY_PASSWORD=your_password
AIRPAY_ENCRYPTION_KEY=your_encryption_key

# Backend URL (for callbacks)
BACKEND_URL=https://admin.moneyone.co.in
FRONTEND_URL=https://client.moneyone.co.in
```

### Getting Airpay Credentials

Contact Airpay support to obtain:
- `CLIENT_ID`: OAuth2 client identifier
- `CLIENT_SECRET`: OAuth2 client secret
- `MERCHANT_ID`: Your merchant ID
- `USERNAME`: API username
- `PASSWORD`: API password
- `ENCRYPTION_KEY`: AES encryption key (32 characters)

## Step 2: Install Required Packages

```bash
cd backend
pip install pycryptodome requests python-dotenv
```

## Step 3: Database Setup

Ensure your `payin_transactions` table has the required columns:

```sql
ALTER TABLE payin_transactions 
ADD COLUMN IF NOT EXISTS pg_partner VARCHAR(50),
ADD COLUMN IF NOT EXISTS pg_txn_id VARCHAR(100),
ADD COLUMN IF NOT EXISTS bank_ref_no VARCHAR(100),
ADD COLUMN IF NOT EXISTS payment_mode VARCHAR(20);
```

## Step 4: Register Routes in app.py

Add the following to your `backend/app.py`:

```python
# Import Airpay V4 routes
from airpay_callback_routes_v4 import airpay_callback_v4_bp

# Register blueprints
app.register_blueprint(airpay_callback_v4_bp)
```

## Step 5: Configure Service Routing

Add Airpay as a payment gateway option in your `service_routing` table:

```sql
INSERT INTO service_routing (
    merchant_id, 
    service_type, 
    pg_partner, 
    is_active, 
    priority
) VALUES (
    'your_merchant_id',
    'PAYIN',
    'Airpay',
    1,
    1
);
```

## Step 6: Test the Integration

Run the comprehensive test script:

```bash
cd backend
python test_airpay_v4_complete.py
```

Expected output:
```
✅ PASS - OAuth2 Token Generation
✅ PASS - Encryption/Decryption
✅ PASS - Generate QR Code
✅ PASS - Verify Payment

Total: 4/4 tests passed
🎉 All tests passed! Airpay V4 integration is working correctly.
```

## API Endpoints

### 1. Generate OAuth2 Token

**Endpoint**: `POST /airpay/pay/v4/api/oauth2`

**Request**:
```json
{
    "client_id": "your_client_id",
    "client_secret": "your_client_secret",
    "merchant_id": 123,
    "grant_type": "client_credentials"
}
```

**Response**:
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

### 2. Generate QR Code

**Endpoint**: `POST /airpay/pay/v4/api/generateorder/?token=<access_token>`

**Request** (encrypted):
```json
{
    "data": "encrypted_payload",
    "encryptionkey": "your_encryption_key"
}
```

**Payload** (before encryption):
```json
{
    "orderid": "ORD123456",
    "amount": "100.00",
    "tid": "12345678",
    "buyer_email": "customer@example.com",
    "buyer_phone": "9999999999",
    "mer_dom": "aHR0cDovL2xvY2FsaG9zdA==",
    "customvar": "merchant_id=123|txn_id=TXN123",
    "call_type": "upiqr"
}
```

**Response** (encrypted):
```json
{
    "status_code": "200",
    "response_code": "00",
    "status": "Success",
    "message": "success",
    "data": {
        "qrcode_string": "upi://pay?pa=example@icici&pn=Merchant&cu=INR&tn=Payment&am=100.00&tr=APS17722152",
        "ap_transactionid": "17722152",
        "status": "200"
    }
}
```

### 3. Verify Payment Status

**Endpoint**: `POST /airpay/pay/v4/api/verify/?token=<access_token>`

**Request** (encrypted):
```json
{
    "data": "encrypted_payload",
    "encryptionkey": "your_encryption_key"
}
```

**Payload** (before encryption):
```json
{
    "orderid": "ORD123456"
}
```

**Response** (encrypted):
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
        "rrn": "016153570198200"
    }
}
```

### 4. Callback (IPN)

**Endpoint**: `POST /api/callback/airpay/v4/payin`

**Request** (encrypted):
```json
{
    "data": "encrypted_payload",
    "encryptionkey": "your_encryption_key"
}
```

**Payload** (decrypted):
```json
{
    "merchant_id": 45,
    "ap_transactionid": "4324324",
    "amount": "1999.00",
    "transaction_status": 200,
    "message": "Success",
    "orderid": "ORDER123",
    "rrn": "016153570198200",
    "chmod": "upi"
}
```

## Transaction Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | SUCCESS | Transaction successful |
| 211 | PROCESSING | Transaction in progress |
| 400 | FAILED | Transaction failed |
| 401 | DROPPED | Transaction not registered properly |
| 402 | CANCEL | Payment not yet processed |
| 403 | INCOMPLETE | No callback from bank |
| 405 | BOUNCED | Transaction bounced |
| 503 | NO RECORDS | No records found |

## Encryption/Decryption Details

### Encryption Process

1. Generate 8-byte random IV
2. Convert IV to hex string (16 characters)
3. Encrypt JSON data using AES-256-CBC
4. Encode encrypted data to base64
5. Return: `IV_hex + base64(encrypted_data)`

### Decryption Process

1. Extract first 16 characters as IV
2. Extract remaining as base64 encrypted data
3. Decode base64
4. Decrypt using AES-256-CBC with IV
5. Remove PKCS5 padding
6. Parse JSON

## Troubleshooting

### Issue: Token generation fails

**Solution**: Verify your `CLIENT_ID`, `CLIENT_SECRET`, and `MERCHANT_ID` are correct.

### Issue: Encryption/Decryption fails

**Solution**: Ensure `ENCRYPTION_KEY` is exactly as provided by Airpay (32 characters).

### Issue: QR generation fails

**Solution**: Check that all required fields are provided and properly formatted.

### Issue: Callback not received

**Solution**: 
1. Verify callback URL is publicly accessible (HTTPS)
2. Check firewall settings
3. Test callback endpoint manually

## Security Best Practices

1. **Never expose credentials**: Keep `.env` file secure
2. **Use HTTPS**: All API calls and callbacks must use HTTPS
3. **Validate callbacks**: Verify `ap_SecureHash` in callbacks
4. **Implement idempotency**: Prevent duplicate wallet credits
5. **Log all transactions**: Maintain audit trail

## Support

For Airpay API support:
- Email: support@airpay.co.in
- Documentation: https://docs.airpay.co.in

For MoneyOne integration support:
- Check logs: `backend/logs/`
- Database: Review `payin_transactions` table
- Test endpoint: `/api/callback/airpay/v4/test`

## Next Steps

1. Test in UAT environment
2. Verify all transaction flows
3. Test callback handling
4. Monitor for 24 hours
5. Go live in production

---

**Last Updated**: March 12, 2026
**Version**: 1.0
**Status**: Production Ready
