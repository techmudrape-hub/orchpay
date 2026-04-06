# Airpay Quick Fix - Test with API Domain as Merchant Domain

## Problem
Error: "Domain id not registered" when creating QR orders.

## Root Cause
The `mer_dom` parameter contains `client.moneyone.co.in` which is NOT registered with Airpay.
Only `api.orchpay.in` is currently whitelisted.

## Quick Test Solution

Try using the already-whitelisted `api.orchpay.in` as the merchant domain temporarily.

### Step 1: Update .env file

```bash
cd /var/www/moneyone/moneyone/backend

# Backup current .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Update FRONTEND_URL to use API domain temporarily
nano .env
```

Change this line:
```env
FRONTEND_URL=https://client.moneyone.co.in
```

To:
```env
FRONTEND_URL=https://api.orchpay.in
```

### Step 2: Test QR Generation

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
python3 test_airpay_qr_generation.py
```

### Step 3: If Successful, Restart Backend

```bash
sudo systemctl restart moneyone-backend
sudo systemctl status moneyone-backend
```

### Step 4: Test from Frontend

Try creating a payin order from your merchant dashboard.

---

## If This Works

This confirms that:
1. ✅ The API integration is correct
2. ✅ OAuth2, encryption, and QR generation all work
3. ❌ Only the merchant domain `client.moneyone.co.in` needs to be registered

**Next Step**: Contact Airpay to register `client.moneyone.co.in` as merchant domain.

---

## If This Doesn't Work

Then we need to ask Airpay to register ALL three domains:
1. `api.orchpay.in` (API calls)
2. `client.moneyone.co.in` (merchant domain)
3. `admin.moneyone.co.in` (admin panel - optional)

---

## Restore Original Configuration

If the test doesn't work or after Airpay registers the correct domain:

```bash
cd /var/www/moneyone/moneyone/backend

# Restore from backup
cp .env.backup.* .env

# Or manually change back
nano .env
# Change FRONTEND_URL back to: https://client.moneyone.co.in

# Restart backend
sudo systemctl restart moneyone-backend
```

---

## Commands Summary

```bash
# Quick test with API domain
cd /var/www/moneyone/moneyone/backend
cp .env .env.backup
sed -i 's|FRONTEND_URL=https://client.moneyone.co.in|FRONTEND_URL=https://api.orchpay.in|g' .env
source venv/bin/activate
python3 test_airpay_qr_generation.py

# If successful
sudo systemctl restart moneyone-backend

# If failed, restore
cp .env.backup .env
sudo systemctl restart moneyone-backend
```
