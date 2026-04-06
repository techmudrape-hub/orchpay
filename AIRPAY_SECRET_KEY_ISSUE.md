# Airpay Secret Key Issue - Merchant Key Authentication Failed

## Current Status

✅ **Private Key Generation**: Working correctly  
❌ **Verify API**: Failing with "Merchant Key Authentication Failed"

## Error Details

```
"status_code": "108"
"message": "Authentication/Authorization Failed - Merchant Key Authentication Failed."
```

## Root Cause Analysis

### Issue 1: Wrong Secret Value

The privatekey formula is:
```
privatekey = SHA256(secret@username:|:password)
```

We're currently using `client_secret` as the `secret`, but Airpay likely requires a **different secret value** specifically for the verify API.

**Current:**
- Secret: `87a3bb9a5bd5d248354f45eca114eda7` (client_secret)
- Username: `5jfP5PJgQz`
- Password: `mAhXEpu7`
- Private Key: `0bdd405b77878badc4715893938ec00cbf29104aeeeaf0fa9b763cba4332193e`

### Issue 2: Merchant ID Mismatch

The transactions you're trying to verify were created with:
- **Old Merchant ID**: `7679022140`
- **Order IDs**: `AP_7679022140_ORD...`

But you're now using:
- **New Merchant ID**: `354479`

**You cannot verify transactions from a different merchant ID!**

## Solutions

### Solution 1: Get Correct Secret from Airpay

Contact Airpay support and request:

**Email Template:**
```
Subject: Request for Secret Key for Verify API - Merchant ID 354479

Dear Airpay Support,

We are implementing the Airpay V4 verify/check status API and need the correct "secret" value for privatekey generation.

Merchant Details:
- Merchant ID: 354479
- Username: 5jfP5PJgQz
- Client ID: c1c537

According to your documentation, the privatekey is generated as:
privatekey = SHA256(secret@username:|:password)

Please provide the correct "secret" value to use in this formula.

Current Issue:
We are receiving error code 108: "Merchant Key Authentication Failed"

Thank you.
```

### Solution 2: Test with New Transactions

Create NEW transactions with the current merchant ID (354479) and test the verify API with those.

**Steps:**
1. Generate a new QR code (will use merchant 354479)
2. Complete the payment
3. Try to verify the transaction
4. Check if it works

### Solution 3: Alternative - Use Merchant 7679022140 Credentials

If you still have access to the old merchant credentials, you could:
1. Get the secret for merchant 7679022140
2. Verify those old transactions
3. Use merchant 354479 for new transactions

## Testing Plan

### Test 1: Create New Transaction with Current Merchant

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate

# Generate QR with current merchant (354479)
python3 test_airpay_qr_generation.py
```

This will create a transaction with order ID like:
```
AP_354479_ORD...
```

Then try to verify THIS transaction (not the old ones).

### Test 2: Check if Secret is in Airpay Dashboard

1. Login to Airpay merchant dashboard
2. Look for API credentials section
3. Check if there's a "Secret Key" or "API Secret" field
4. This might be different from client_secret

### Test 3: Try Different Secret Values

Sometimes the secret is:
- The encryption key
- The merchant ID itself
- A combination of credentials

Let me create a test script to try different possibilities:

## Temporary Workaround

Until you get the correct secret from Airpay, you can:

1. **Rely on IPN Callbacks**: Airpay will send callbacks when payments complete
2. **Use Auto Status Check**: The 60-second auto check will keep trying
3. **Manual Status Updates**: Update transactions manually when you receive callbacks

## What's Working

✅ OAuth2 token generation  
✅ QR code generation  
✅ Encryption/Decryption  
✅ Callback handler (ready to receive)  
✅ Private key generation (formula is correct)  

## What's NOT Working

❌ Verify API - Wrong secret value  
❌ Cannot verify old merchant transactions with new merchant credentials  

## Immediate Action Required

**Option A: Contact Airpay Support**
- Request the correct "secret" value for merchant 354479
- Ask about verify API authentication requirements

**Option B: Test with New Transactions**
- Create a new transaction with merchant 354479
- Try to verify it immediately
- This will confirm if the issue is merchant mismatch or secret value

**Option C: Check Airpay Dashboard**
- Login to merchant portal
- Look for API secret/key
- Try that value as the secret

## Update Configuration

Once you get the correct secret from Airpay:

1. Update `.env`:
```bash
AIRPAY_SECRET=<actual_secret_from_airpay>
```

2. Restart backend:
```bash
sudo systemctl restart moneyone-backend
```

3. Test verify API:
```bash
python3 test_airpay_check_status.py
```

## Expected Behavior After Fix

Once you have the correct secret:
- ✅ Verify API will work
- ✅ Check status by order ID will work
- ✅ Check status by transaction ID will work
- ✅ Auto status check will update transactions
- ✅ Transactions will move from INITIATED to SUCCESS/FAILED

## Summary

The privatekey generation is working correctly, but Airpay is rejecting it because:
1. The `secret` value is incorrect (need actual secret from Airpay)
2. OR you're trying to verify transactions from a different merchant ID

**Next Steps:**
1. Contact Airpay support for the correct secret value
2. OR create new transactions with merchant 354479 and test with those
3. Update AIRPAY_SECRET in .env once you have it
4. Restart backend and test

The integration is 95% complete - we just need the correct secret value from Airpay!
