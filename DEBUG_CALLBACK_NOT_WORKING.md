# Debug Guide: Callbacks Not Working Automatically

This guide helps diagnose why callbacks are not being sent automatically after a transaction is successful.

## Step 1: Check Callback Configuration

Run the diagnostic script to check if the callback URL is properly stored:

```bash
cd /home/ubuntu/moneyone/backend

# Check by order ID
python3 check_callback_config.py --order-id "YOUR_ORDER_ID"

# Or check by merchant ID
python3 check_callback_config.py --merchant-id "7679022140"
```

This will show you:
- Whether the transaction has a callback_url stored
- Whether the merchant has a callback URL in merchant_callbacks table
- Recent transactions and their callback URLs
- Recent callback logs

## Step 2: Check Backend Logs

Check if Mudrape is actually calling your callback endpoint:

```bash
# Check gunicorn logs
sudo journalctl -u gunicorn -f

# Or check application logs
tail -f /home/ubuntu/moneyone/backend/app.log
```

Look for these log messages:
- `"Mudrape Payin Callback Received"` - Mudrape called your endpoint
- `"Transaction callback_url: ..."` - Shows what URL was found in transaction
- `"Merchant callback_url: ..."` - Shows what URL was found in merchant_callbacks
- `"Forwarding callback to merchant: ..."` - Callback is being sent
- `"Merchant callback response: ..."` - Response from merchant's server

## Step 3: Verify Mudrape is Calling Your Endpoint

Check if Mudrape is actually sending callbacks to your server:

```bash
# Check nginx access logs
sudo tail -f /var/log/nginx/access.log | grep callback

# Check for Mudrape callback requests
sudo grep "mudrape/payin" /var/log/nginx/access.log | tail -20
```

You should see POST requests to `/api/callback/mudrape/payin`

## Step 4: Check Database for Callback URL

```bash
mysql -u root -p moneyone_db
```

```sql
-- Check if transaction has callback URL
SELECT 
    txn_id, 
    order_id, 
    callback_url, 
    status, 
    created_at 
FROM payin_transactions 
WHERE order_id = 'YOUR_ORDER_ID';

-- Check merchant_callbacks table
SELECT * FROM merchant_callbacks WHERE merchant_id = '7679022140';

-- Check callback logs
SELECT 
    txn_id,
    callback_url,
    response_code,
    LEFT(response_data, 100) as response,
    created_at
FROM callback_logs 
ORDER BY created_at DESC 
LIMIT 10;
```

## Step 5: Test Callback URL Manually

Test if the merchant's callback URL is reachable from your server:

```bash
cd /home/ubuntu/moneyone/backend
python3 test_merchant_callback.py
```

This will send a test payload to `https://hab.pay777.co.uk/call-mone`

## Step 6: Manual Callback Trigger

If automatic callbacks aren't working, trigger manually:

```bash
cd /home/ubuntu/moneyone/backend

# For a specific transaction
python3 manual_callback_trigger.py --order-id "YOUR_ORDER_ID"

# With custom URL
python3 manual_callback_trigger.py --order-id "YOUR_ORDER_ID" --callback-url "https://hab.pay777.co.uk/call-mone"
```

## Common Issues and Solutions

### Issue 1: Callback URL is NULL or Empty

**Symptom:** Diagnostic shows `callback_url: NULL` or `callback_url: ''`

**Solution:** The callback URL is not being stored when creating the order. Check:
1. Is the merchant sending `callbackurl` in the payin payload?
2. Has the backend been restarted after code changes?

**Fix:** Ensure the payin payload includes:
```json
{
  "amount": "100",
  "orderid": "ORD123",
  "payee_fname": "John",
  "payee_mobile": "9876543210",
  "payee_email": "john@example.com",
  "callbackurl": "https://hab.pay777.co.uk/call-mone"
}
```

### Issue 2: Mudrape Not Calling Your Endpoint

**Symptom:** No logs showing "Mudrape Payin Callback Received"

**Solution:** Mudrape hasn't been configured with your callback URL.

**Fix:** Contact Mudrape support and provide:
- Callback URL: `https://api.orchpay.in/api/callback/mudrape/payin`
- Method: POST
- Content-Type: application/json

### Issue 3: Callback URL Not Reachable

**Symptom:** Logs show "Failed to send merchant callback: Connection refused"

**Solution:** The merchant's server is not reachable.

**Possible causes:**
- Merchant's server is down
- URL is incorrect
- Firewall blocking your server's IP
- SSL certificate issues

**Fix:** 
1. Test with curl: `curl -X POST https://hab.pay777.co.uk/call-mone -H "Content-Type: application/json" -d '{"test":"data"}'`
2. Ask merchant to whitelist your server IP
3. Verify the URL is correct

### Issue 4: Backend Not Restarted

**Symptom:** Code changes not taking effect

**Solution:** Restart the backend:

```bash
sudo systemctl restart gunicorn
sudo systemctl status gunicorn
```

### Issue 5: Callback Sent But Merchant Not Receiving

**Symptom:** Logs show "Merchant callback sent successfully" but merchant says they didn't receive it

**Solution:** Check the response code in callback_logs:

```sql
SELECT 
    callback_url,
    response_code,
    response_data,
    created_at
FROM callback_logs 
WHERE txn_id = 'YOUR_TXN_ID';
```

- **200-299**: Success - merchant received it (check their logs)
- **400-499**: Merchant's server rejected it (check payload format)
- **500-599**: Merchant's server error
- **0**: Connection failed

## Step-by-Step Debugging Process

1. **Create a test transaction**
   - Use the merchant dashboard or API
   - Include `callbackurl` in the payload

2. **Check if callback URL was stored**
   ```bash
   python3 check_callback_config.py --order-id "YOUR_ORDER_ID"
   ```

3. **Complete the payment**
   - Scan QR code and pay
   - Wait for Mudrape to send callback

4. **Check backend logs**
   ```bash
   sudo journalctl -u gunicorn -f
   ```
   Look for callback forwarding messages

5. **Check callback_logs table**
   ```sql
   SELECT * FROM callback_logs ORDER BY created_at DESC LIMIT 5;
   ```

6. **If no logs, Mudrape isn't calling your endpoint**
   - Verify Mudrape has your callback URL configured
   - Check nginx logs for incoming requests

7. **If logs show error, debug the specific error**
   - Connection error: Check merchant's server
   - Timeout: Merchant's server is slow
   - HTTP error: Check response_data for details

## Quick Fix Checklist

- [ ] Backend has been restarted after code changes
- [ ] Transaction has callback_url stored in database
- [ ] Mudrape has your callback URL configured
- [ ] Merchant's callback URL is reachable (test with curl)
- [ ] Callback logs show successful delivery (response_code 200)
- [ ] Merchant's server is processing callbacks correctly

## Need More Help?

Check the callback_logs table for detailed error messages:

```sql
SELECT 
    txn_id,
    callback_url,
    request_data,
    response_code,
    response_data,
    created_at
FROM callback_logs 
WHERE merchant_id = '7679022140'
ORDER BY created_at DESC 
LIMIT 10;
```

This will show you exactly what was sent and what response was received.
