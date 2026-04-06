# Airpay V4 API - Quick Reference Guide

## Quick Start

### 1. Add Credentials to .env
```bash
AIRPAY_BASE_URL=https://kraken.airpay.co.in
AIRPAY_CLIENT_ID=your_client_id
AIRPAY_CLIENT_SECRET=your_client_secret
AIRPAY_MERCHANT_ID=your_merchant_id
AIRPAY_USERNAME=your_username
AIRPAY_PASSWORD=your_password
AIRPAY_ENCRYPTION_KEY=your_encryption_key
```

### 2. Deploy Integration
```bash
chmod +x deploy_airpay_v4_integration.sh
./deploy_airpay_v4_integration.sh
```

### 3. Test Integration
```bash
cd backend
python3 test_airpay_v4_complete.py
```

## API Flow

```
1. Generate OAuth2 Token
   ↓
2. Encrypt Request Data
   ↓
3. Generate QR Code
   ↓
4. Customer Scans & Pays
   ↓
5. Receive Callback (IPN)
   ↓
6. Decrypt Callback Data
   ↓
7. Update Transaction Status
   ↓
8. Credit Merchant Wallet
```

## Key Files

| File | Purpose |
|------|---------|
| `airpay_service_v4.py` | Core service with OAuth2, encryption, QR generation |
| `airpay_callback_routes_v4.py` | Callback handler for IPN |
| `test_airpay_v4_complete.py` | Complete integration test |
| `AIRPAY_V4_CONFIGURATION_GUIDE.md` | Detailed setup guide |

## Common Commands

### Test OAuth2 Token
```python
from airpay_service_v4 import airpay_service_v4
token = airpay_service_v4.generate_access_token()
print(token)
```

### Test Encryption
```python
from airpay_service_v4 import airpay_service_v4
data = {'test': 'data'}
encrypted = airpay_service_v4.encrypt_data(data)
decrypted = airpay_service_v4.decrypt_data(encrypted)
print(decrypted)
```

### Generate QR Code
```python
from airpay_service_v4 import airpay_service_v4
order_data = {
    'orderid': 'TEST123',
    'amount': '100.00',
    'buyer_email': 'test@example.com',
    'buyer_phone': '9999999999',
    'mer_dom': 'aHR0cDovL2xvY2FsaG9zdA==',
    'customvar': 'test',
    'call_type': 'upiqr'
}
result = airpay_service_v4.generate_qr(order_data)
print(result)
```

### Check Payment Status
```python
from airpay_service_v4 import airpay_service_v4
result = airpay_service_v4.verify_payment(order_id='ORD123')
print(result)
```

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | SUCCESS |
| 211 | PROCESSING |
| 400 | FAILED |
| 401 | DROPPED |
| 402 | CANCEL |
| 403 | INCOMPLETE |
| 405 | BOUNCED |
| 503 | NO RECORDS |

## Callback URL

**Production**: `https://admin.moneyone.co.in/api/callback/airpay/v4/payin`

**Test**: `https://admin.moneyone.co.in/api/callback/airpay/v4/test`

## Troubleshooting

### Token Generation Fails
```bash
# Check credentials
grep AIRPAY_ backend/.env

# Test manually
curl -X POST https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2 \
  -H "Content-Type: application/json" \
  -d '{"client_id":"YOUR_ID","client_secret":"YOUR_SECRET","merchant_id":123,"grant_type":"client_credentials"}'
```

### Encryption Fails
```bash
# Verify encryption key length (should be 32 chars)
python3 -c "from config import Config; print(len(Config.AIRPAY_ENCRYPTION_KEY))"
```

### Callback Not Received
```bash
# Test callback endpoint
curl -X POST https://admin.moneyone.co.in/api/callback/airpay/v4/payin \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'

# Check logs
tail -f /var/log/backend.log | grep -i airpay
```

## Monitoring

### Check Recent Transactions
```sql
SELECT txn_id, order_id, amount, status, pg_txn_id, bank_ref_no, created_at
FROM payin_transactions
WHERE pg_partner = 'Airpay'
ORDER BY created_at DESC
LIMIT 10;
```

### Check Callback Logs
```sql
SELECT txn_id, callback_url, response_status, created_at
FROM callback_logs
WHERE callback_url LIKE '%airpay%'
ORDER BY created_at DESC
LIMIT 10;
```

### Monitor Service
```bash
# Check backend status
sudo systemctl status backend

# View logs
tail -f /var/log/backend.log

# Filter Airpay logs
tail -f /var/log/backend.log | grep -i airpay
```

## Support Contacts

**Airpay Support**:
- Email: support@airpay.co.in
- Phone: Check Airpay dashboard
- Docs: https://docs.airpay.co.in

**Technical Issues**:
- Check: `AIRPAY_V4_CONFIGURATION_GUIDE.md`
- Test: `python3 test_airpay_v4_complete.py`
- Logs: `/var/log/backend.log`

---

**Quick Tip**: Always test in UAT environment before production deployment!
