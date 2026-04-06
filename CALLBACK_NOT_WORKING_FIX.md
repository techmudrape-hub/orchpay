# Fix: Mudrape Callback Not Working Automatically

## Problem
Callback from Mudrape is only triggered when clicking "Check Status" button manually. The automatic callback after payment completion is not working.

## Root Cause Analysis

There are several possible reasons:

### 1. Mudrape Not Sending Callback
- Callback URL not properly configured on Mudrape's side
- Mudrape's callback system has issues
- Payment gateway not triggering callback

### 2. Callback Being Blocked
- Firewall blocking Mudrape's IP
- Nginx not routing callback correctly
- SSL certificate issues

### 3. Callback Failing Silently
- Database connection issues
- Field name mismatches
- Transaction not found errors

## Diagnostic Steps

### Step 1: Check if Callback Endpoint is Accessible

```bash
# Test from external source (not from server itself)
curl -X POST https://api.orchpay.in/api/callback/mudrape/payin \
  -H "Content-Type: application/json" \
  -d '{"ref_id":"TEST123","status":"SUCCESS","txn_id":"TEST_TXN","amount":100}' \
  -v
```

Expected response: `{"success":false,"message":"Transaction not found"}` (This is OK - it means endpoint is working)

### Step 2: Check Server Logs for Callback Attempts

```bash
# Check if Mudrape is sending callbacks
sudo journalctl -u moneyone-api --since "1 hour ago" | grep -i "payin callback"

# Check for any callback errors
sudo journalctl -u moneyone-api --since "1 hour ago" | grep -i "ERROR.*callback"
```

### Step 3: Check Nginx Access Logs

```bash
# Check if requests are reaching Nginx
sudo tail -f /var/log/nginx/api.orchpay.in.access.log | grep callback

# Check for errors
sudo tail -f /var/log/nginx/api.orchpay.in.error.log
```

### Step 4: Verify Callback URL with Mudrape

Contact Mudrape support and verify:
1. Callback URL is set to: `https://api.orchpay.in/api/callback/mudrape/payin`
2. Callback is enabled for your merchant account
3. Ask them to check their logs for callback attempts

## Solutions

### Solution 1: Add Callback URL to QR Creation Request

Mudrape might require callback URL to be sent with each transaction. Update the QR creation to include callback URL.

**File: `backend/mudrape_service.py`**

Find the `create_payin_order` method and ensure it includes `callbackUrl`:

```python
payload = {
    'amount': amount,
    'refId': order_id,
    'payeeName': payee_name,
    'payeeMobile': payee_mobile,
    'payeeEmail': payee_email,
    'callbackUrl': 'https://api.orchpay.in/api/callback/mudrape/payin',  # Add this
    'remarks': remarks
}
```

### Solution 2: Implement Polling Mechanism

Since callbacks are unreliable, implement automatic status polling for pending transactions.

Create a background job that checks INITIATED transactions every 30 seconds.

### Solution 3: Add More Detailed Logging

Update callback route to log ALL incoming requests, even before processing.

### Solution 4: Whitelist Mudrape IPs (if using firewall)

If you have UFW or firewall enabled, ensure Mudrape's IPs are whitelisted.

## Recommended Fix: Add Callback URL to Transaction + Polling

I'll implement both solutions for reliability.
