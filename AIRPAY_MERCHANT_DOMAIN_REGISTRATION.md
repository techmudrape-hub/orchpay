# Airpay Merchant Domain Registration - URGENT

## Problem Summary

**Error**: "Authentication Operation Failed - Domain id not registered" (Response Code: U04)

**Cause**: The merchant domain (`mer_dom` parameter) is not registered in Airpay's system.

## What's Already Working ✅

1. OAuth2 token generation - Working perfectly
2. API domain `api.orchpay.in` - Already whitelisted
3. Callback URL `https://api.orchpay.in/api/callback/airpay/payin` - Already whitelisted

## What Needs to be Fixed ❌

**Merchant Domain Registration Required**

The `mer_dom` parameter in our generateOrder API request contains:
- Domain: `client.moneyone.co.in`
- Full URL: `https://client.moneyone.co.in`
- Base64 Encoded: `aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=`

This domain needs to be registered as the merchant domain for Merchant ID 354479.

---

## Email to Send to Airpay Support

**To**: Airpay Support Team  
**Subject**: URGENT: Register Merchant Domain for Merchant 354479

---

Dear Airpay Support Team,

We need to register our merchant domain for Merchant ID 354479.

**Merchant Information:**
- Merchant ID: 354479
- Client ID: c1c537

**Current Issue:**
We are receiving error "Authentication Operation Failed - Domain id not registered" (U04) when calling the generateOrder API.

**Domain to Register:**
Please register the following as our merchant domain (mer_dom):
```
client.moneyone.co.in
```

**Technical Details:**
- This domain is sent as the `mer_dom` parameter in generateOrder API
- Base64 encoded value: `aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=`
- Our API domain (api.orchpay.in) is already whitelisted and working
- Our callback URL is already whitelisted and working

**Request:**
Please register `client.moneyone.co.in` as the merchant domain for Merchant ID 354479 so we can proceed with QR generation.

Thank you for your prompt assistance.

Best regards,
[Your Name]
[Your Contact Information]

---

## Alternative: Try Using API Domain as Merchant Domain

If Airpay support is slow to respond, you can try using the already-whitelisted API domain as the merchant domain temporarily.

### Option 1: Update .env file

Change in `backend/.env`:
```env
# Try using API domain as merchant domain temporarily
FRONTEND_URL=https://api.orchpay.in
```

### Option 2: Test with API domain

Run this test:
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate

# Update .env temporarily
sed -i 's|FRONTEND_URL=https://client.moneyone.co.in|FRONTEND_URL=https://api.orchpay.in|g' .env

# Test QR generation
python3 test_airpay_qr_generation.py

# If it works, restart backend
sudo systemctl restart moneyone-backend
```

### Option 3: Hardcode API domain in code (temporary)

Edit `backend/airpay_service.py` around line 651:
```python
# Temporary fix: Use API domain as merchant domain
frontend_url = os.getenv('BACKEND_URL', 'https://api.orchpay.in')
mer_dom = base64.b64encode(frontend_url.encode()).decode()
```

---

## Understanding the mer_dom Parameter

The `mer_dom` (merchant domain) parameter is:
1. The domain where your merchant frontend is hosted
2. Sent as base64 encoded in the generateOrder API
3. Must be registered in Airpay's system for your merchant ID
4. Used by Airpay for security and domain validation

**Example:**
- Original: `https://client.moneyone.co.in`
- Base64: `aHR0cHM6Ly9jbGllbnQubW9uZXlvbmUuY28uaW4=`

---

## Testing After Domain Registration

Once Airpay confirms the domain is registered, test with:

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_qr_generation.py
```

Expected output:
```
✅ SUCCESS!
QR String: upi://pay?...
Transaction ID: AP_...
```

---

## Summary

**Action Required**: Contact Airpay support to register `client.moneyone.co.in` as merchant domain for Merchant ID 354479

**Temporary Workaround**: Use `api.orchpay.in` as merchant domain (already whitelisted)

**Permanent Solution**: Wait for Airpay to register `client.moneyone.co.in`

---

## Quick Commands

### Test current configuration:
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_qr_generation.py
```

### Try with API domain as merchant domain:
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate

# Backup current .env
cp .env .env.backup

# Update FRONTEND_URL
sed -i 's|FRONTEND_URL=https://client.moneyone.co.in|FRONTEND_URL=https://api.orchpay.in|g' .env

# Test
python3 test_airpay_qr_generation.py

# If successful, restart backend
sudo systemctl restart moneyone-backend

# If failed, restore backup
cp .env.backup .env
```

### Check current configuration:
```bash
cd /var/www/moneyone/moneyone/backend
cat .env | grep -E "(BACKEND_URL|FRONTEND_URL|AIRPAY_)"
```

---

## Contact Information for Airpay

**What to tell them:**
1. Merchant ID: 354479
2. Need to register merchant domain: `client.moneyone.co.in`
3. This is for the `mer_dom` parameter in generateOrder API
4. Currently getting error U04: "Domain id not registered"
5. API domain and callback URL are already working

**Expected response:**
- Confirmation that domain is registered
- Estimated time for activation (usually immediate)
- Any additional requirements
