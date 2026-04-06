# Airpay 403 Error - Troubleshooting Guide

## Error Details

```
Response Status: 403
Response Body: 403 Forbidden: Access is denied. Parameters are required.
```

## Root Cause

The 403 error indicates that Airpay's API is blocking your request. This is most commonly due to:

1. **IP Address Not Whitelisted** (Most Common)
2. Wrong API credentials
3. Account not activated
4. Wrong API endpoint

## Solution Steps

### Step 1: Get Your Server IP Address

Run this command on your server:

```bash
curl ifconfig.me
```

Or:

```bash
curl ipinfo.io/ip
```

**Your Server IP**: (Note this down)

### Step 2: Contact Airpay Support

Send an email to Airpay support with the following information:

**To**: support@airpay.co.in  
**Subject**: IP Whitelisting Request for Merchant ID 335854

**Email Body**:
```
Dear Airpay Support Team,

We are integrating Airpay V4 API for our payment gateway and receiving a 403 error when calling the OAuth2 token endpoint.

Please whitelist the following IP address for our merchant account:

Merchant ID: 335854
Server IP Address: [YOUR_IP_FROM_STEP_1]
API Endpoint: https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2

Error Details:
- Status Code: 403
- Error Message: "Access is denied. Parameters are required"

Please confirm once the IP has been whitelisted so we can proceed with testing.

Thank you,
[Your Name]
[Your Company]
```

### Step 3: Verify Credentials

While waiting for IP whitelisting, verify your credentials are correct:

```bash
cd backend
python3 diagnose_airpay_token.py
```

Check that all values are present:
- ✓ AIRPAY_BASE_URL
- ✓ AIRPAY_CLIENT_ID
- ✓ AIRPAY_CLIENT_SECRET
- ✓ AIRPAY_MERCHANT_ID
- ✓ AIRPAY_USERNAME
- ✓ AIRPAY_PASSWORD
- ✓ AIRPAY_ENCRYPTION_KEY

### Step 4: Test Different Formats (Optional)

Try different request formats to see if any work:

```bash
cd backend
python3 test_airpay_token_formats.py
```

This will test:
1. JSON format
2. Form URL-encoded format
3. Different merchant_id types
4. Alternative endpoints

### Step 5: Check NAT Gateway IP (If Using AWS)

If you're using AWS with a NAT Gateway, you need to whitelist the **NAT Gateway's Elastic IP**, not the EC2 instance IP.

To find your NAT Gateway IP:

```bash
# Get your public IP as seen by external services
curl ifconfig.me

# Or check AWS Console:
# VPC → NAT Gateways → Select your NAT → Check "Elastic IP address"
```

### Step 6: Test After Whitelisting

Once Airpay confirms IP whitelisting, test again:

```bash
cd backend
python3 diagnose_airpay_token.py
```

Expected output after whitelisting:
```
✅ Token generation SUCCESSFUL!
```

## Common Issues

### Issue 1: Multiple Server IPs

If you have multiple backend servers (load balanced), you need to whitelist ALL server IPs or use a NAT Gateway with a single Elastic IP.

**Solution**: 
- Use NAT Gateway with Elastic IP (recommended)
- Or whitelist all backend server IPs

### Issue 2: Dynamic IP Address

If your server IP changes, you'll get 403 errors again.

**Solution**:
- Use Elastic IP (AWS)
- Or use NAT Gateway with Elastic IP
- Contact Airpay to update whitelisted IP

### Issue 3: Wrong Endpoint

The V4 API endpoint should be:
```
https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2
```

If this doesn't work, try:
```
https://kraken.airpay.co.in/airpay/pay/api/oauth2
```

### Issue 4: Credentials Issue

Verify with Airpay that:
- CLIENT_ID is correct
- CLIENT_SECRET is correct
- MERCHANT_ID is correct
- Account is activated for V4 API

## Testing Checklist

- [ ] Get server IP address
- [ ] Email Airpay support for IP whitelisting
- [ ] Verify all credentials in .env file
- [ ] Wait for Airpay confirmation
- [ ] Test token generation
- [ ] If successful, proceed with QR generation
- [ ] Test complete payment flow

## Quick Test Commands

```bash
# Check your IP
curl ifconfig.me

# Test token generation
cd backend
python3 diagnose_airpay_token.py

# Test different formats
python3 test_airpay_token_formats.py

# Check backend logs
tail -f /var/log/backend.log | grep -i airpay
```

## Airpay Support Contact

**Email**: support@airpay.co.in  
**Phone**: Check your Airpay dashboard  
**Documentation**: https://docs.airpay.co.in

## Expected Timeline

- IP whitelisting request: Usually processed within 1-2 business days
- After whitelisting: Token generation should work immediately

## Next Steps After Fix

Once token generation works:

1. Test QR code generation
2. Test payment verification
3. Test callback handling
4. Go live with production

---

**Note**: The 403 error is a security feature. It's normal for payment gateways to require IP whitelisting for API access.
