# Mudrape Callback Verification Guide

## Quick Verification Steps

### Method 1: Automated Test (Recommended)

**Upload and run the Python verification script:**

```bash
# On your production server
cd /var/www/moneyone/moneyone

# Make script executable
chmod +x verify_callback_setup.py

# Run verification
python3 verify_callback_setup.py
```

This will test:
- ✓ SSL certificate validity
- ✓ Payout callback endpoint accessibility
- ✓ Payin callback endpoint accessibility
- ✓ Payout callback data processing
- ✓ Payin callback data processing

### Method 2: Bash Script Test

```bash
# On your production server
cd /var/www/moneyone/moneyone

# Make script executable
chmod +x test_callback_integration.sh

# Run test
./test_callback_integration.sh
```

### Method 3: Manual cURL Tests

**Test Payout Callback:**
```bash
curl -X POST https://api.orchpay.in/api/callback/mudrape/payout \
  -H "Content-Type: application/json" \
  -d '{
    "clientTxnId": "TEST_SF20260222000000",
    "statusCode": 10000,
    "payoutStatus": "SUCCESS",
    "utr": "TEST701297876158",
    "transactionId": "MUDRAPE_TEST_123",
    "data": {
      "txnId": "MUDRAPE_TEST_123",
      "bankRefNo": "TEST701297876158",
      "processedAt": "2026-02-22T12:34:56+05:30"
    }
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Transaction not found"
}
```
This is GOOD - it means the endpoint is working but the test transaction doesn't exist.

**Test Payin Callback:**
```bash
curl -X POST https://api.orchpay.in/api/callback/mudrape/payin \
  -H "Content-Type: application/json" \
  -d '{
    "refId": "TEST_ORDER_123",
    "txnId": "MUDRAPE_PAYIN_TEST",
    "status": "SUCCESS",
    "utr": "TEST701297876158",
    "amount": 300
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Transaction not found"
}
```
This is also GOOD - endpoint is working correctly.

---

## Verification Checklist

### ✓ Pre-Verification Checks

- [ ] Backend service is running
  ```bash
  sudo systemctl status moneyone-api
  ```

- [ ] Nginx is running and configured correctly
  ```bash
  sudo nginx -t
  sudo systemctl status nginx
  ```

- [ ] SSL certificates are valid
  ```bash
  sudo certbot certificates
  ```

- [ ] Firewall allows HTTPS traffic
  ```bash
  sudo ufw status | grep 443
  ```

### ✓ Endpoint Accessibility

- [ ] Payout callback endpoint responds
  ```bash
  curl -I -X POST https://api.orchpay.in/api/callback/mudrape/payout
  ```
  Expected: HTTP 400 or 200 (not 404 or 502)

- [ ] Payin callback endpoint responds
  ```bash
  curl -I -X POST https://api.orchpay.in/api/callback/mudrape/payin
  ```
  Expected: HTTP 400 or 200 (not 404 or 502)

### ✓ Mudrape Configuration

- [ ] Mudrape team has configured payout callback URL
- [ ] Mudrape team has configured payin callback URL
- [ ] Mudrape team has tested callbacks from their side
- [ ] Mudrape team confirmed "success" status

### ✓ Real Transaction Test

After Mudrape confirms configuration:

1. **Initiate a small test payout** (₹10-50)
2. **Monitor logs in real-time:**
   ```bash
   sudo tail -f /var/log/moneyone/error.log | grep -i "callback\|mudrape"
   ```

3. **Check if callback was received:**
   - Look for "Mudrape Payout Callback Received" in logs
   - Verify transaction status updated in database

4. **Verify database update:**
   ```bash
   mysql -u moneyone_user -p moneyone_db
   ```
   ```sql
   SELECT txn_id, reference_id, status, utr, pg_txn_id, completed_at, updated_at
   FROM payout_transactions
   ORDER BY updated_at DESC
   LIMIT 5;
   ```

---

## What to Look For in Logs

### Successful Callback Log Pattern:

```
================================================================================
Mudrape Payout Callback Received
================================================================================
Callback Data: {
  "clientTxnId": "SF20260222123456ABC123",
  "statusCode": 10000,
  "payoutStatus": "SUCCESS",
  ...
}
Client TXN ID: SF20260222123456ABC123
Status Code: 10000
Payout Status: SUCCESS
UTR: 701297876158
Mapped Status: SUCCESS
Found Transaction: TXN123456, Current Status: PENDING
✓ Updated with completed_at from Mudrape: 2026-02-22 12:34:56
Verification - Status: SUCCESS, UTR: 701297876158, PG_TXN_ID: MUDRAPE123
================================================================================
Callback processed successfully
================================================================================
```

### Failed Callback Indicators:

- `ERROR: No clientTxnId in callback` - Mudrape not sending required field
- `ERROR: Transaction not found` - Reference ID mismatch
- `ERROR: Database connection failed` - Database issue
- `ERROR in callback:` - Python exception occurred

---

## Troubleshooting

### Issue 1: Endpoint Returns 404

**Cause:** Route not registered or Nginx misconfigured

**Fix:**
```bash
# Check if blueprint is registered
cd /var/www/moneyone/moneyone/backend
grep "mudrape_callback_bp" app.py

# Should see:
# from mudrape_callback_routes import mudrape_callback_bp
# app.register_blueprint(mudrape_callback_bp)

# Restart backend
sudo systemctl restart moneyone-api
```

### Issue 2: Endpoint Returns 502 Bad Gateway

**Cause:** Backend service not running

**Fix:**
```bash
sudo systemctl status moneyone-api
sudo systemctl restart moneyone-api
sudo journalctl -u moneyone-api -n 50
```

### Issue 3: Callback Received but Not Processing

**Cause:** Database connection issue or data format mismatch

**Fix:**
```bash
# Check application logs
sudo tail -f /var/log/moneyone/error.log

# Check database connection
mysql -u moneyone_user -p moneyone_db -e "SELECT 1"

# Verify payout_transactions table structure
mysql -u moneyone_user -p moneyone_db -e "DESCRIBE payout_transactions"
```

### Issue 4: Status Not Updating

**Cause:** Reference ID mismatch or ENUM value issue

**Fix:**
```bash
# Check if ENUM includes all required values
mysql -u moneyone_user -p moneyone_db

SHOW COLUMNS FROM payout_transactions LIKE 'status';

# Should include: PENDING, INITIATED, QUEUED, PROCESSING, INPROCESS, SUCCESS, FAILED, REVERSED
```

---

## Monitoring Commands

### Real-time Callback Monitoring
```bash
# Watch for any callback activity
sudo tail -f /var/log/moneyone/error.log | grep -i "callback"

# Watch specifically for Mudrape callbacks
sudo tail -f /var/log/moneyone/error.log | grep -i "mudrape.*callback"

# Watch for callback errors
sudo tail -f /var/log/moneyone/error.log | grep -i "error.*callback"
```

### Check Recent Transactions
```bash
# Recent payouts
mysql -u moneyone_user -p moneyone_db -e "
SELECT 
  txn_id, 
  reference_id, 
  status, 
  utr, 
  pg_txn_id,
  DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created,
  DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated
FROM payout_transactions
ORDER BY updated_at DESC
LIMIT 10;
"

# Recent payins
mysql -u moneyone_user -p moneyone_db -e "
SELECT 
  txn_id, 
  order_id, 
  status, 
  utr, 
  pg_txn_id,
  DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created,
  DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated
FROM payin_transactions
ORDER BY updated_at DESC
LIMIT 10;
"
```

### Check Callback Statistics
```bash
# Count callbacks received today
sudo grep "Mudrape.*Callback Received" /var/log/moneyone/error.log | \
  grep "$(date +%Y-%m-%d)" | wc -l

# Count successful callbacks today
sudo grep "Callback processed successfully" /var/log/moneyone/error.log | \
  grep "$(date +%Y-%m-%d)" | wc -l
```

---

## Confirmation for Mudrape Team

Once all tests pass, confirm with Mudrape team:

✅ **Callback URLs Configured:**
- Payout: `https://api.orchpay.in/api/callback/mudrape/payout`
- Payin: `https://api.orchpay.in/api/callback/mudrape/payin`

✅ **Endpoints Tested:**
- Both endpoints are accessible via HTTPS
- Both endpoints accept POST requests with JSON payload
- Both endpoints return proper HTTP status codes

✅ **Ready for Production:**
- SSL certificates are valid
- Backend service is running
- Database is configured
- Logging is enabled

✅ **Request from Mudrape:**
- Perform a test transaction from their side
- Confirm they see successful callback delivery
- Verify transaction status updates in your system

---

## Success Criteria

Your callback integration is successful when:

1. ✓ Mudrape team confirms callbacks are configured
2. ✓ Test transactions trigger callbacks
3. ✓ Callbacks appear in application logs
4. ✓ Transaction statuses update in database
5. ✓ UTR numbers are captured correctly
6. ✓ Timestamps are recorded properly
7. ✓ No errors in logs during callback processing

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**Status:** Ready for Production Testing
