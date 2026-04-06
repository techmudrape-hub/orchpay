# Check Mudrape Callback Format

## Problem
Need to verify if Mudrape sends callbacks as JSON or multipart/form-data

## Solution 1: Check Backend Logs

### Step 1: Enable Detailed Logging
The callback route now logs:
- Content-Type header
- All request headers
- Data format (JSON, Form, or Raw)
- Complete callback payload

### Step 2: Monitor Logs
```bash
# Watch for callbacks in real-time
tail -f backend.log | grep -A 50 "Mudrape Payin Callback"
```

### Step 3: Look for These Lines
```
Content-Type: application/json          # ← JSON format
Content-Type: application/x-www-form-urlencoded  # ← Form data
Content-Type: multipart/form-data       # ← Multipart

Received as JSON                        # ← Parsed as JSON
Received as Form Data                   # ← Parsed as form
Received as Raw Data                    # ← Raw bytes
```

## Solution 2: Use Callback Capture Server

### Step 1: Start Capture Server
```bash
cd backend
python test_callback_capture.py
```

This starts a server on port 5001 that captures ALL callback data.

### Step 2: Expose Server (for testing)

**Option A: Using ngrok**
```bash
# Install ngrok: https://ngrok.com/download
ngrok http 5001

# You'll get a URL like: https://abc123.ngrok.io
```

**Option B: Direct IP (if server is public)**
```
http://YOUR_SERVER_IP:5001/test-callback
```

### Step 3: Configure in Mudrape Dashboard
1. Login to Mudrape merchant dashboard
2. Go to Settings → Webhooks
3. Set callback URL to:
   ```
   https://YOUR_NGROK_URL/test-callback
   ```
   OR
   ```
   http://YOUR_SERVER_IP:5001/test-callback
   ```

### Step 4: Make a Test Payment
1. Generate QR code
2. Make a small test payment
3. Wait for callback

### Step 5: View Captured Data
```bash
# View in terminal (server shows it automatically)

# Or view via API
curl http://localhost:5001/view-callbacks

# Or check the file
cat backend/captured_callbacks.json
```

## Solution 3: Check Existing Logs

### Search for Content-Type in Logs
```bash
grep -A 5 "Content-Type" backend.log | grep -A 5 "Mudrape"
```

### Search for Callback Data
```bash
grep -A 30 "Mudrape Payin Callback Received" backend.log | tail -100
```

## What to Look For

### If Mudrape Sends JSON:
```
Content-Type: application/json
Received as JSON
Callback Data: {
  "refId": "...",
  "txnId": "...",
  "status": "SUCCESS",
  ...
}
```

### If Mudrape Sends Form Data:
```
Content-Type: application/x-www-form-urlencoded
Received as Form Data
Callback Data: {
  "refId": "...",
  "txnId": "...",
  "status": "SUCCESS",
  ...
}
```

### If Mudrape Sends Multipart:
```
Content-Type: multipart/form-data; boundary=...
Received as Form Data
Callback Data: {
  "refId": "...",
  ...
}
```

## Updated Callback Handler

The callback route now handles ALL formats:
- ✅ JSON (`application/json`)
- ✅ Form data (`application/x-www-form-urlencoded`)
- ✅ Multipart (`multipart/form-data`)
- ✅ Raw data (tries to parse as JSON)

## Testing

### Test JSON Callback
```bash
curl -X POST http://localhost:5000/api/callback/mudrape/payin \
  -H "Content-Type: application/json" \
  -d '{
    "refId": "20241234567890123456",
    "txnId": "MPAY_TEST",
    "status": "SUCCESS",
    "amount": 300
  }'
```

### Test Form Data Callback
```bash
curl -X POST http://localhost:5000/api/callback/mudrape/payin \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "refId=20241234567890123456&txnId=MPAY_TEST&status=SUCCESS&amount=300"
```

### Check Logs
```bash
tail -f backend.log | grep -A 30 "Mudrape Payin Callback"
```

## Deployment

After updating the callback handler:

```bash
bash deploy_mudrape_final.sh
```

## Verification Checklist

- [ ] Backend logs show "Content-Type" header
- [ ] Backend logs show "Received as JSON" or "Received as Form Data"
- [ ] Callback data is properly parsed
- [ ] Transaction status updates correctly
- [ ] Wallet is credited on SUCCESS

## Common Issues

### Issue: "No data received"
**Cause:** Mudrape not sending callback or wrong URL
**Fix:** 
1. Verify callback URL in Mudrape dashboard
2. Check backend is accessible
3. Check firewall allows HTTPS

### Issue: "Invalid data format"
**Cause:** Unexpected data format
**Fix:**
1. Check backend logs for Content-Type
2. Check raw data in logs
3. Update callback handler if needed

### Issue: Callback received but not parsed
**Cause:** Data format not recognized
**Fix:**
1. Check logs for "Received as..." message
2. Check callback_data value
3. May need to add custom parsing

## Contact Mudrape Support

If callback format is unclear, ask Mudrape:

**Questions to Ask:**
1. What Content-Type header do you send?
2. Is the payload JSON or form-data?
3. Can you provide a sample callback payload?
4. What are the exact field names? (refId vs ref_id)

**Information to Provide:**
- Your merchant ID
- Callback URL: `https://admin.moneyone.co.in/api/callback/mudrape/payin`
- Sample transaction that should trigger callback
- Confirmation that endpoint is accessible

## Summary

The callback handler now:
- ✅ Logs Content-Type and all headers
- ✅ Supports JSON, form-data, and multipart
- ✅ Logs data format received
- ✅ Provides detailed error messages
- ✅ Saves all data for debugging

Use the capture server or check logs to see exactly what Mudrape sends!
