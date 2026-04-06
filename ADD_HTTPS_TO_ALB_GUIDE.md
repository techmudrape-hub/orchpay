# Add HTTPS to Application Load Balancer - Complete Guide

## Overview
Currently your ALB only supports HTTP (port 80). To enable HTTPS, you need to:
1. Request a free SSL certificate from AWS Certificate Manager
2. Add HTTPS listener to your ALB
3. Update your application to use HTTPS

## Step 1: Import Your Existing Let's Encrypt Certificate to AWS ACM

You already have a valid Let's Encrypt certificate on your EC2 instance that covers:
- admin.moneyone.co.in
- api.orchpay.in
- partner.moneyone.co.in

Valid until: May 23, 2026 (80 days remaining)

### 1.1 Separate the Certificate Chain

Your fullchain.pem contains TWO certificates that need to be separated:

**On your EC2 instance, run these commands:**

```bash
# Extract ONLY the first certificate (domain certificate)
sudo cat /etc/letsencrypt/live/admin.moneyone.co.in/fullchain.pem | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {if (++count==1) print}' > /tmp/domain_cert.pem

# Extract ONLY the second certificate (intermediate certificate)
sudo cat /etc/letsencrypt/live/admin.moneyone.co.in/fullchain.pem | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {if (++count==2) print}' > /tmp/intermediate_cert.pem

# Copy the private key
sudo cp /etc/letsencrypt/live/admin.moneyone.co.in/privkey.pem /tmp/privkey.pem

# Make files readable
sudo chmod 644 /tmp/domain_cert.pem /tmp/intermediate_cert.pem /tmp/privkey.pem

# Display the files for copying
echo "=== DOMAIN CERTIFICATE ==="
cat /tmp/domain_cert.pem
echo ""
echo "=== INTERMEDIATE CERTIFICATE (CHAIN) ==="
cat /tmp/intermediate_cert.pem
echo ""
echo "=== PRIVATE KEY ==="
cat /tmp/privkey.pem
```

### 1.2 Go to AWS Certificate Manager
1. Open AWS Console
2. Search for "Certificate Manager" or "ACM"
3. Make sure you're in the **ap-south-1 (Mumbai)** region
4. Click "Import certificate"

### 1.3 Import Certificate

**Fill in the three fields:**

1. **Certificate body**: Paste the content from `/tmp/domain_cert.pem`
   - This is the FIRST certificate (starts with `-----BEGIN CERTIFICATE-----`)
   - Should contain: `admin.moneyone.co.in` in the subject

2. **Certificate private key**: Paste the content from `/tmp/privkey.pem`
   - Starts with `-----BEGIN PRIVATE KEY-----`

3. **Certificate chain**: Paste the content from `/tmp/intermediate_cert.pem`
   - This is the SECOND certificate (Let's Encrypt E8 intermediate)
   - Should contain: `Let's Encrypt` in the issuer

### 1.4 Add Tags (Optional)
- Key: Name
- Value: moneyone-letsencrypt-certificate
- Click "Next"

### 1.5 Review and Import
1. Review your certificate details
2. You should see:
   - Domain names: admin.moneyone.co.in, api.orchpay.in, partner.moneyone.co.in
   - Expiration: May 23, 2026
3. Click "Import"

**Important**: The certificate will be imported immediately - no validation needed since you already own the private key!

## Step 2: Certificate Imported Successfully

After import, you should see:
- Status: "Issued" (green checkmark)
- In use: No (will change to "Yes" after adding to ALB)
- Domains: admin.moneyone.co.in, api.orchpay.in, partner.moneyone.co.in
- Expires: May 23, 2026

## Step 3: Add HTTPS Listener to ALB

### 3.1 Go to Load Balancers
1. Open EC2 Console
2. Click "Load Balancers" in left menu
3. Select your ALB: `moneyone-alb`

### 3.2 Add HTTPS Listener
1. Go to "Listeners" tab
2. Click "Add listener"
3. Configure:
   - **Protocol**: HTTPS
   - **Port**: 443
   - **Default action**: Forward to
   - **Target group**: moneyone-backend-tg
   - **Security policy**: ELBSecurityPolicy-TLS13-1-2-2021-06 (recommended)
4. Click "Add" under "Default SSL/TLS certificate"
5. Select "From ACM"
6. Choose your certificate: `moneyone-ssl-certificate`
7. Click "Add"

### 3.3 Update Security Group
Your ALB security group needs to allow HTTPS traffic:

1. Go to "Security" tab
2. Click on the security group (moneyone-alb-sg)
3. Click "Edit inbound rules"
4. Add new rule:
   - **Type**: HTTPS
   - **Protocol**: TCP
   - **Port**: 443
   - **Source**: 0.0.0.0/0 (Anywhere IPv4)
   - **Description**: Allow HTTPS from internet
5. Click "Save rules"

## Step 4: Optional - Redirect HTTP to HTTPS

### 4.1 Modify HTTP Listener
1. Go back to Load Balancers → Listeners
2. Select the HTTP:80 listener
3. Click "Edit"
4. Change default action:
   - **Action type**: Redirect to URL
   - **Protocol**: HTTPS
   - **Port**: 443
   - **Status code**: 301 (Permanent redirect)
5. Click "Save changes"

This will automatically redirect all HTTP traffic to HTTPS.

## Step 5: Update Environment Variables

### 5.1 Update Frontend .env Files

**moneyone_admin/.env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

**moneyone_client/.env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

### 5.2 Rebuild Frontend Applications

**On your development machine or server:**

```bash
# Admin portal
cd moneyone_admin
npm run build

# Merchant portal
cd ../moneyone_client
npm run build
```

### 5.3 Deploy Updated Builds
Copy the `dist` folders to your hosting location.

## Step 6: Update Backend CORS Configuration

### 6.1 Update backend/.env

Add your HTTPS domains to CORS_ORIGINS:

```env
CORS_ORIGINS=https://admin.moneyone.co.in,https://partner.moneyone.co.in,https://moneyone.co.in,http://localhost:5173,http://localhost:5174
```

### 6.2 Restart Backend Service

```bash
sudo systemctl restart moneyone-api
```

## Step 7: Test HTTPS Configuration

### 7.1 Test API Endpoint
```bash
curl https://api.orchpay.in/health
```

Expected response:
```json
{"status":"healthy"}
```

### 7.2 Test in Browser
1. Open: https://admin.moneyone.co.in/login
2. Check browser console - no SSL errors
3. Try logging in - should work without "Failed to fetch" errors

### 7.3 Verify SSL Certificate
1. Click the padlock icon in browser address bar
2. Should show "Connection is secure"
3. Certificate should be valid for your domain

## Troubleshooting

### Issue 1: Certificate Stuck in "Pending validation"
**Solution:**
- Double-check CNAME records in Hostinger
- Make sure you entered only the prefix (without domain)
- Wait up to 30 minutes for DNS propagation
- Use `nslookup _abc123.moneyone.co.in` to verify CNAME exists

### Issue 2: "NET::ERR_CERT_AUTHORITY_INVALID"
**Solution:**
- Certificate not yet issued - wait for validation
- Wrong certificate selected in ALB listener
- Certificate doesn't include the domain you're accessing

### Issue 3: Still getting "Failed to fetch"
**Solution:**
- Clear browser cache
- Check if HTTPS listener is active in ALB
- Verify security group allows port 443
- Check backend CORS configuration includes HTTPS domains

### Issue 4: Mixed Content Warnings
**Solution:**
- Make sure ALL API calls use HTTPS
- Update all environment variables to use https://
- Rebuild frontend applications

## Summary of Changes

After completing this guide, you'll have:

✅ Free SSL certificate from AWS Certificate Manager
✅ HTTPS listener on ALB (port 443)
✅ HTTP to HTTPS redirect (optional)
✅ Secure connections for all API calls
✅ No more "Failed to fetch" errors
✅ Professional, secure application

## Quick Reference

**Your URLs after HTTPS setup:**
- API: https://api.orchpay.in
- Admin: https://admin.moneyone.co.in
- Merchant: https://partner.moneyone.co.in

**Certificate validation CNAME format:**
- AWS shows: `_abc123.moneyone.co.in` → `_xyz456.acm-validations.aws`
- Hostinger needs: Name=`_abc123`, Points to=`_xyz456.acm-validations.aws`

---

## Next Steps After HTTPS is Working

1. ✅ Test all application features
2. ✅ Update any hardcoded HTTP URLs to HTTPS
3. ✅ Enable HTTP to HTTPS redirect
4. ✅ Monitor SSL certificate expiration (AWS auto-renews)
5. ✅ Consider adding HSTS headers for extra security

Your application will now be production-ready with secure HTTPS connections!
