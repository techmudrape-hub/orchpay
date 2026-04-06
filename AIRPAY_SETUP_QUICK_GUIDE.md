# Airpay V4 Integration - Quick Setup Guide

## Step 1: Install Dependencies

```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip3 install pycryptodome
```

Or use the installation script:
```bash
cd /var/www/moneyone/moneyone/backend
bash install_airpay_dependencies.sh
```

## Step 2: Verify Configuration

Check that backend/.env has correct credentials:
```
AIRPAY_CLIENT_ID=c1c537
AIRPAY_CLIENT_SECRET=87a3bb9a5bd5d248354f45eca114eda7
AIRPAY_MERCHANT_ID=335854
AIRPAY_USERNAME=CKFzeZGut2
AIRPAY_PASSWORD=WRx4M373
AIRPAY_ENCRYPTION_KEY=bb0f9631717c57a6b7fcb2e2e4a30205
```

## Step 3: Test OAuth2 Token Generation

```bash
cd /var/www/moneyone/moneyone/backend
python3 test_airpay_oauth2_complete.py
```

Expected output:
```
✅ SUCCESS! OAuth2 Token Generated
📝 Access Token: [40-character token]
```

## Step 4: Restart Backend Service

```bash
sudo systemctl restart moneyone-backend
```

## Troubleshooting

### Error: No module named 'Crypto'
Solution: Install pycryptodome
```bash
pip3 install pycryptodome
```

### Error: Invalid client id or secret
Solution: Verify credentials in backend/.env match:
- Client ID: c1c537
- Client Secret: 87a3bb9a5bd5d248354f45eca114eda7

### Error: Invalid Checksum
This should be resolved. If you still see it, contact Airpay support.

## Files Modified

1. backend/.env - Updated credentials
2. backend/airpay_service.py - Fixed OAuth2 implementation
3. backend/install_airpay_dependencies.sh - Dependency installer

## Next Steps

Once OAuth2 is working:
1. Test QR code generation
2. Test payment verification
3. Test callback handling
4. Deploy to production
