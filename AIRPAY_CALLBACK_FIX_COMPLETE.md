# Airpay Callback Processing Fix - Complete Guide

## Problem Identified

The Airpay callback was being received and decrypted successfully, but the transaction status was not being updated and merchant callbacks were not being forwarded.

### Root Cause

**Order ID Mismatch**: Airpay truncates or modifies the order_id in their callback response.

- **Stored in DB**: `AP_7679022140_ORD88787876765564632_20260312190000` (with timestamp)
- **Returned in Callback**: `AP_7679022140_ORD887878767655646` (truncated/modified)

This caused the database lookup to fail, preventing status updates and callback forwarding.

## Solution Implemented

### 1. Enhanced Transaction Lookup

Modified `backend/airpay_callback_routes.py` to use a more robust transaction lookup strategy:

```python
# Step 1: Extract txn_id from customvar field (most reliable)
if customvar and 'txn_id=' in customvar:
    # Parse: "merchant_id=XXX|txn_id=YYY|callback_url=ZZZ"
    txn_id_from_customvar = extract_txn_id(customvar)
    
    # Lookup by txn_id (exact match)
    SELECT * FROM payin_transactions WHERE txn_id = %s

# Step 2: Fallback to order_id with partial matching
else:
    # Try exact match first, then partial match with LIKE
    SELECT * FROM payin_transactions 
    WHERE (order_id = %s OR order_id LIKE %s)
```

### 2. Callback Flow

The complete callback processing flow:

1. **Receive Callback** → Airpay sends encrypted POST request
2. **Decrypt Data** → Using AES-256-CBC with encryption key
3. **Extract Transaction ID** → From customvar field (reliable)
4. **Find Transaction** → Using txn_id or partial order_id match
5. **Update Status** → Map Airpay status codes to our statuses
6. **Credit Wallets** → If SUCCESS and not already credited
7. **Forward to Merchant** → Extract callback URL from customvar
8. **Log Callback** → Record in callback_logs table

## Status Mapping

Airpay status codes mapped to our system:

| Airpay Code | Status | Description |
|-------------|--------|-------------|
| 200 | SUCCESS | Transaction successful |
| 211 | PROCESSING | Transaction processing |
| 400 | FAILED | Transaction failed |
| 401 | FAILED | Not registered properly |
| 402 | FAILED | Not yet processed |
| 403 | FAILED | No callback from bank |
| 405 | FAILED | Transaction bounced |
| 503 | NOT_FOUND | No records found |

## Deployment

### Deploy the Fix

```bash
chmod +x deploy_airpay_callback_fix.sh
./deploy_airpay_callback_fix.sh
```

### Manual Testing

Process the latest callback manually:

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 process_airpay_callback_manual.py
```

### Check Transaction Status

```bash
python3 check_airpay_callback_issue.py
```

## Verification Steps

### 1. Check Latest Transaction

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 check_airpay_callback_issue.py
```

This will show:
- Latest Airpay transaction details
- Wallet credit status
- Callback logs
- Merchant callback configuration

### 2. Process Test Transaction

1. Create a test transaction via merchant dashboard
2. Complete payment via UPI
3. Wait for callback (usually within 30 seconds)
4. Check transaction status:

```bash
python3 -c "
import pymysql
from config import DB_CONFIG

conn = pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)
cursor = conn.cursor()

cursor.execute('''
    SELECT txn_id, order_id, status, pg_txn_id, bank_ref_no, updated_at
    FROM payin_transactions
    WHERE pg_partner = \"Airpay\"
    ORDER BY created_at DESC
    LIMIT 1
''')

txn = cursor.fetchone()
print(f\"Transaction: {txn['txn_id']}\")
print(f\"Order ID: {txn['order_id']}\")
print(f\"Status: {txn['status']}\")
print(f\"PG Txn ID: {txn['pg_txn_id']}\")
print(f\"UTR: {txn['bank_ref_no']}\")
print(f\"Updated: {txn['updated_at']}\")

conn.close()
"
```

### 3. Verify Wallet Credits

```bash
python3 -c "
import pymysql
from config import DB_CONFIG

conn = pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)
cursor = conn.cursor()

# Get latest Airpay transaction
cursor.execute('''
    SELECT txn_id FROM payin_transactions
    WHERE pg_partner = \"Airpay\"
    ORDER BY created_at DESC LIMIT 1
''')
txn = cursor.fetchone()

if txn:
    cursor.execute('''
        SELECT merchant_id, amount, txn_type, description, created_at
        FROM merchant_wallet_transactions
        WHERE reference_id = %s
    ''', (txn['txn_id'],))
    
    credits = cursor.fetchall()
    for c in credits:
        print(f\"{c['txn_type']}: ₹{c['amount']} - {c['description']}\")

conn.close()
"
```

### 4. Check Callback Logs

```bash
python3 -c "
import pymysql
from config import DB_CONFIG

conn = pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)
cursor = conn.cursor()

cursor.execute('''
    SELECT txn_id, callback_url, response_code, created_at
    FROM callback_logs
    WHERE txn_id LIKE \"AIRPAY_%\"
    ORDER BY created_at DESC
    LIMIT 5
''')

logs = cursor.fetchall()
for log in logs:
    print(f\"{log['created_at']}: {log['txn_id']} -> {log['callback_url']} (HTTP {log['response_code']})\")

conn.close()
"
```

## Monitoring

### Check Server Logs

```bash
# Real-time logs
sudo journalctl -u moneyone-api -f

# Recent errors
sudo journalctl -u moneyone-api -n 100 --no-pager | grep -i error

# Airpay-specific logs
sudo journalctl -u moneyone-api -n 200 --no-pager | grep -i airpay
```

### Check Callback Log Files

```bash
# View today's callbacks
tail -f /var/www/moneyone/moneyone/backend/logs/airpay_callbacks_$(date +%Y%m%d).log

# Search for specific order
grep "AP_7679022140" /var/www/moneyone/moneyone/backend/logs/airpay_callbacks_*.log
```

## Troubleshooting

### Issue: Transaction Not Found

**Symptom**: Callback received but "Transaction not found" error

**Solution**:
1. Check if order_id in callback matches database
2. Verify customvar contains correct txn_id
3. Use manual processing script to debug

```bash
python3 process_airpay_callback_manual.py
```

### Issue: Wallet Not Credited

**Symptom**: Status updated but wallet balance unchanged

**Check**:
```bash
python3 -c "
import pymysql
from config import DB_CONFIG

conn = pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)
cursor = conn.cursor()

cursor.execute('''
    SELECT COUNT(*) as count FROM merchant_wallet_transactions
    WHERE reference_id = 'YOUR_TXN_ID' AND txn_type = 'UNSETTLED_CREDIT'
''')

result = cursor.fetchone()
print(f\"Wallet credits found: {result['count']}\")
conn.close()
"
```

### Issue: Merchant Callback Not Sent

**Symptom**: Status updated, wallet credited, but merchant didn't receive callback

**Check**:
1. Verify callback URL in customvar field
2. Check callback_logs table
3. Verify merchant's callback endpoint is accessible

```bash
# Test merchant callback endpoint
curl -X POST https://merchant-callback-url.com/callback \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## Key Files

- `backend/airpay_callback_routes.py` - Main callback handler
- `backend/airpay_service.py` - Airpay service integration
- `backend/process_airpay_callback_manual.py` - Manual processing script
- `backend/check_airpay_callback_issue.py` - Diagnostic script
- `/var/www/moneyone/moneyone/backend/logs/airpay_callbacks_*.log` - Callback logs

## Important Notes

1. **Idempotency**: Wallet credits are protected against duplicate callbacks
2. **Customvar Field**: Contains merchant_id, txn_id, and callback_url
3. **Order ID Format**: Airpay may truncate long order IDs
4. **Callback URL**: Extracted from customvar, fallback to merchant_callbacks table
5. **Status Mapping**: Airpay uses numeric codes (200, 211, 400, etc.)

## Next Steps

1. Monitor production transactions for 24 hours
2. Verify all callbacks are processed correctly
3. Check merchant feedback on callback delivery
4. Consider adding webhook retry mechanism for failed callbacks

## Support

If issues persist:
1. Check server logs: `sudo journalctl -u moneyone-api -f`
2. Run diagnostic script: `python3 check_airpay_callback_issue.py`
3. Process manually: `python3 process_airpay_callback_manual.py`
4. Review callback logs in `/var/www/moneyone/moneyone/backend/logs/`
