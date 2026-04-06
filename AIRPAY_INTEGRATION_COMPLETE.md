# Airpay Integration Complete Guide

## Overview
This document provides a complete guide for the Airpay payin integration that has been implemented in the MoneyOne system.

## What Was Implemented

### 1. Airpay Service (`backend/airpay_service.py`)
- **AES Encryption/Decryption**: Implements AES/CBC/PKCS5PADDING encryption as required by Airpay
- **OAuth2 Token Management**: Handles access token generation and refresh
- **Order Creation**: Creates payin orders with QR code generation
- **Status Checking**: Checks payment status from Airpay API
- **Automatic Status Updates**: Background status checking for pending transactions
- **Wallet Integration**: Credits merchant and admin wallets on successful payments

### 2. Airpay Routes (`backend/airpay_routes.py`)
- **Order Creation API**: `/api/airpay/order/create` - Creates encrypted payin orders
- **Status Check APIs**: 
  - `/api/airpay/status/<txn_id>` - Check by transaction ID
  - `/api/airpay/status/order/<order_id>` - Check by order ID
- **JWT Authentication**: All routes require valid merchant JWT tokens
- **AES Encryption**: Request/response encryption using merchant AES keys

### 3. Airpay Callback Handler (`backend/airpay_callback_routes.py`)
- **IPN Processing**: Handles Airpay Instant Payment Notifications
- **Hash Verification**: Verifies Airpay callback authenticity using CRC32 hash
- **Status Updates**: Updates transaction status and credits wallets
- **Merchant Callbacks**: Forwards notifications to merchant callback URLs
- **Idempotency**: Prevents duplicate wallet credits

### 4. Service Routing Integration
- **Gateway Selection**: Added Airpay to available payment gateways
- **Routing Configuration**: Supports both single-user and all-users routing
- **Admin Management**: Configurable through admin dashboard

### 5. Configuration Management
- **Environment Variables**: All Airpay credentials stored in `.env`
- **Encryption Key Generation**: MD5 hash of username and password
- **Base URL Configuration**: Supports both test and production environments

## Configuration

### Environment Variables Required
```bash
# Airpay Configuration
AIRPAY_BASE_URL=https://kraken.airpay.co.in
AIRPAY_CLIENT_ID=4b88dcc
AIRPAY_CLIENT_SECRET=51d68722cca2b4bb096262c326bd24bb
AIRPAY_MERCHANT_ID=335854
AIRPAY_USERNAME=CKFzeZGut2
AIRPAY_PASSWORD=WRx4M373
AIRPAY_ENCRYPTION_KEY=V8GqK8T6RC4ajHM8
```

### Airpay Dashboard Configuration
You need to configure the following callback URL in your Airpay merchant dashboard:
```
https://your-domain.com/api/callback/airpay/payin
```

## API Endpoints

### 1. Create Payin Order
**Endpoint**: `POST /api/payin/order/create`
**Authentication**: JWT Token
**Request**: Encrypted JSON payload
```json
{
  "data": "encrypted_payload_containing_order_details"
}
```

**Encrypted Payload Structure**:
```json
{
  "amount": 100.00,
  "orderid": "ORDER123",
  "payee_fname": "John",
  "payee_lname": "Doe",
  "payee_mobile": "9999999999",
  "payee_email": "john@example.com",
  "callbackurl": "https://merchant.com/callback"
}
```

**Response**: Encrypted JSON with QR code and transaction details

### 2. Check Payment Status
**Endpoint**: `GET /api/airpay/status/<txn_id>`
**Authentication**: JWT Token
**Response**: Transaction status and details

### 3. Callback Endpoint
**Endpoint**: `POST /api/callback/airpay/payin`
**Authentication**: None (public endpoint for Airpay)
**Purpose**: Receives payment notifications from Airpay

## Transaction Flow

### 1. Order Creation Flow
```
Merchant Dashboard → Create Order → Airpay Service → Generate QR → Return to Merchant
```

### 2. Payment Flow
```
Customer Scans QR → Pays via UPI → Airpay Processes → Sends Callback → Updates Status → Credits Wallet
```

### 3. Status Update Flow
```
Callback Received → Verify Hash → Update Transaction → Credit Wallets → Forward to Merchant
```

## Status Mapping

| Airpay Status Code | Our Status | Description |
|-------------------|------------|-------------|
| 200 | SUCCESS | Payment successful |
| 211 | INITIATED | Payment processing |
| 400, 401, 402, 403, 405 | FAILED | Payment failed |
| Others | INITIATED | Default status |

## Security Features

### 1. AES Encryption
- **Algorithm**: AES-256-CBC with PKCS5 padding
- **Key Generation**: MD5 hash of username and password
- **IV**: Random 16-byte initialization vector per request

### 2. Hash Verification
- **Algorithm**: CRC32 hash verification for callbacks
- **Format**: `crc32(TRANSACTIONID:APTRANSACTIONID:AMOUNT:STATUS:MESSAGE:MID:USERNAME[:CUSTOMERVPA])`

### 3. Authentication
- **JWT Tokens**: All merchant APIs require valid JWT authentication
- **API Credentials**: Secure storage of Airpay credentials in environment variables

## Database Schema

### Payin Transactions Table
The integration uses the existing `payin_transactions` table with these key fields:
- `pg_partner`: Set to 'Airpay'
- `pg_txn_id`: Airpay transaction ID
- `order_id`: Airpay order ID (our generated ID)
- `bank_ref_no`: UTR/RRN from Airpay
- `callback_url`: Merchant callback URL

### Service Routing Table
Airpay is added as a routing option:
- `pg_partner`: 'Airpay'
- `service_type`: 'PAYIN'
- `routing_type`: 'SINGLE_USER' or 'ALL_USERS'

## Deployment

### Files Created/Modified
1. **New Files**:
   - `backend/airpay_service.py`
   - `backend/airpay_routes.py`
   - `backend/airpay_callback_routes.py`
   - `backend/setup_airpay_routing.py`
   - `backend/test_airpay_integration.py`
   - `deploy_airpay_integration.sh`
   - `fix_airpay_import_error.sh`

2. **Modified Files**:
   - `backend/app.py` - Added blueprint registration
   - `backend/config.py` - Added Airpay configuration
   - `backend/payin_routes.py` - Added Airpay routing logic
   - `backend/service_routing_routes.py` - Added Airpay to PG partners
   - `backend/.env` - Added Airpay credentials

### Deployment Steps
1. **Run the fix script**:
   ```bash
   chmod +x fix_airpay_import_error.sh
   ./fix_airpay_import_error.sh
   ```

2. **Setup routing**:
   ```bash
   cd backend
   python3 setup_airpay_routing.py
   ```

3. **Test integration**:
   ```bash
   python3 test_airpay_integration.py
   ```

## Testing

### 1. Unit Tests
- Token generation test
- Encryption/decryption test
- Order creation test
- Status checking test

### 2. Integration Tests
- End-to-end payment flow
- Callback processing
- Wallet crediting
- Error handling

### 3. Manual Testing
1. Create a test order through merchant dashboard
2. Scan QR code and make payment
3. Verify callback is received
4. Check transaction status update
5. Verify wallet credits

## Troubleshooting

### Common Issues

1. **Import Errors**:
   - Run `fix_airpay_import_error.sh`
   - Check all required files are present

2. **Token Generation Fails**:
   - Verify Airpay credentials in `.env`
   - Check network connectivity to Airpay servers

3. **Encryption Errors**:
   - Verify encryption key generation
   - Check AES library installation

4. **Callback Not Received**:
   - Verify callback URL in Airpay dashboard
   - Check firewall/security group settings
   - Test callback endpoint manually

### Debug Commands
```bash
# Check service status
sudo systemctl status moneyone-api

# View logs
sudo journalctl -u moneyone-api -f

# Test callback endpoint
curl -X GET https://your-domain.com/api/callback/airpay/test

# Test imports
cd backend && python3 -c "from airpay_service import airpay_service; print('OK')"
```

## Monitoring

### Key Metrics to Monitor
1. **Transaction Success Rate**: Monitor SUCCESS vs FAILED transactions
2. **Callback Processing**: Ensure callbacks are processed within 30 seconds
3. **Wallet Credits**: Verify all successful payments credit wallets
4. **Error Rates**: Monitor API errors and failures

### Log Monitoring
- Monitor application logs for Airpay-related errors
- Set up alerts for callback processing failures
- Track transaction status update delays

## Production Checklist

- [ ] All environment variables configured
- [ ] Callback URL configured in Airpay dashboard
- [ ] SSL certificate valid for callback URL
- [ ] Firewall allows Airpay callback IPs
- [ ] Database backup before deployment
- [ ] Test transaction completed successfully
- [ ] Monitoring and alerting configured
- [ ] Error handling tested
- [ ] Rollback plan prepared

## Support

### Airpay Support
- **Documentation**: Provided API documentation
- **Support Contact**: Contact Airpay team for API issues

### Internal Support
- **Code Location**: All Airpay code in `backend/airpay_*` files
- **Configuration**: Environment variables in `backend/.env`
- **Logs**: Application logs contain Airpay transaction details

## Future Enhancements

1. **Payout Integration**: Extend to support Airpay payouts
2. **Webhook Retry**: Implement retry mechanism for failed callbacks
3. **Advanced Monitoring**: Add detailed transaction analytics
4. **Multi-Currency**: Support for multiple currencies if Airpay adds support
5. **Bulk Operations**: Support for bulk payment processing

---

**Integration Status**: ✅ Complete and Ready for Production

**Last Updated**: March 12, 2026

**Version**: 1.0.0