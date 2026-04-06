# Complete HTTPS Setup Checklist

## Problem
Your frontend applications are trying to access `https://api.orchpay.in` but getting "ERR_CONNECTION_REFUSED" because:
- ALB only has HTTP listener (port 80)
- No HTTPS listener (port 443) configured
- You have a valid Let's Encrypt certificate on EC2 but it's not being used by ALB

## Solution Overview
Import your existing Let's Encrypt certificate to AWS Certificate Manager (ACM) and add HTTPS listener to ALB.

---

## ✅ STEP 1: Extract Certificates (5 minutes)

**On your EC2 instance:**

```bash
cd /var/www/moneyone/moneyone
bash extract_certificates_for_aws.sh
```

This will display three sections. **Keep this terminal open** - you'll copy from it.

---

## ✅ STEP 2: Import to AWS ACM (3 minutes)

1. Open AWS Console → **Certificate Manager (ACM)**
2. Region: **ap-south-1 (Mumbai)**
3. Click **"Import certificate"**

4. Copy-paste from your terminal:
   - **Certificate body**: First section (domain certificate)
   - **Certificate private key**: Third section (private key)  
   - **Certificate chain**: Second section (intermediate certificate)

5. Click **"Next"** → **"Import"**

**Verify:**
- Status: "Issued" ✅
- Domains: admin.moneyone.co.in, api.orchpay.in, partner.moneyone.co.in
- Expires: May 23, 2026

---

## ✅ STEP 3: Add HTTPS Listener to ALB (3 minutes)

1. **EC2 Console** → **Load Balancers** → Select **moneyone-alb**
2. **"Listeners"** tab → **"Add listener"**

3. Configure:
   - Protocol: **HTTPS**
   - Port: **443**
   - Default action: **Forward to** → **moneyone-backend-tg**
   - Security policy: **ELBSecurityPolicy-TLS13-1-2-2021-06**

4. Default SSL/TLS certificate:
   - Click **"Add"**
   - Select **"From ACM"**
   - Choose your imported certificate

5. Click **"Add"**

---

## ✅ STEP 4: Update Security Group (2 minutes)

1. ALB → **"Security"** tab → Click **moneyone-alb-sg**
2. **"Edit inbound rules"** → **"Add rule"**:
   - Type: **HTTPS**
   - Port: **443**
   - Source: **0.0.0.0/0**
   - Description: **Allow HTTPS from internet**
3. **"Save rules"**

---

## ✅ STEP 5: Test HTTPS (1 minute)

```bash
curl https://api.orchpay.in/health
```

**Expected:**
```json
{"status":"healthy"}
```

**If this works, HTTPS is configured! 🎉**

---

## ✅ STEP 6: Update Frontend .env Files (2 minutes)

**moneyone_admin/.env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

**moneyone_client/.env:**
```env
VITE_API_BASE_URL=https://api.orchpay.in/api
```

---

## ✅ STEP 7: Rebuild Frontend Apps (5 minutes)

```bash
# Admin portal
cd /var/www/moneyone/moneyone/moneyone_admin
npm run build

# Merchant portal
cd /var/www/moneyone/moneyone/moneyone_client
npm run build
```

---

## ✅ STEP 8: Update Backend CORS (2 minutes)

**Edit backend/.env:**

```bash
cd /var/www/moneyone/moneyone/backend
sudo nano .env
```

**Update CORS_ORIGINS to include HTTPS domains:**

```env
CORS_ORIGINS=https://admin.moneyone.co.in,https://partner.moneyone.co.in,https://moneyone.co.in,http://localhost:5173,http://localhost:5174
```

**Restart backend:**

```bash
sudo systemctl restart moneyone-api
```

---

## ✅ STEP 9: Test Everything (5 minutes)

### Test API
```bash
curl https://api.orchpay.in/health
```

### Test Admin Portal
1. Open: https://admin.moneyone.co.in
2. Check browser console - no errors
3. Try logging in - should work

### Test Merchant Portal
1. Open: https://partner.moneyone.co.in
2. Check browser console - no errors
3. Try logging in - should work

### Verify SSL
- Click padlock icon in browser
- Should show "Connection is secure"
- Certificate valid for your domains

---

## 🎯 OPTIONAL: HTTP to HTTPS Redirect (2 minutes)

1. ALB → **"Listeners"** → Select **HTTP:80**
2. Click **"Edit"**
3. Change default action:
   - Action type: **Redirect to URL**
   - Protocol: **HTTPS**
   - Port: **443**
   - Status code: **301**
4. **"Save changes"**

Now all HTTP traffic automatically redirects to HTTPS!

---

## Final Verification Checklist

- [ ] Certificate imported to ACM (Status: Issued)
- [ ] HTTPS listener on ALB (Port 443)
- [ ] Security group allows port 443
- [ ] `curl https://api.orchpay.in/health` works
- [ ] Frontend .env files use HTTPS URLs
- [ ] Frontend apps rebuilt
- [ ] Backend CORS includes HTTPS domains
- [ ] Backend service restarted
- [ ] Admin portal loads via HTTPS
- [ ] Merchant portal loads via HTTPS
- [ ] No "ERR_CONNECTION_REFUSED" errors
- [ ] No "Failed to fetch" errors
- [ ] Browser shows padlock (secure)
- [ ] HTTP redirects to HTTPS (optional)

---

## Troubleshooting

### "Certificate field contains more than one certificate"
✅ **Fixed**: Use `extract_certificates_for_aws.sh` script

### "ERR_CONNECTION_REFUSED" on HTTPS
- Check HTTPS listener is active
- Verify security group allows 443
- Wait 1-2 minutes for ALB update

### "Failed to fetch" errors
- Clear browser cache
- Check CORS includes HTTPS domains
- Verify .env files use HTTPS
- Rebuild frontend apps

### Certificate not in ACM
- Check region: ap-south-1 (Mumbai)
- Verify all three fields filled
- Private key must match certificate

---

## Summary

**Total Time: ~25 minutes**

After completion:
- ✅ HTTPS enabled on ALB
- ✅ Using existing Let's Encrypt certificate
- ✅ No "ERR_CONNECTION_REFUSED" errors
- ✅ Production-ready secure application
- ✅ No new certificate or DNS validation needed

**Your secure URLs:**
- https://api.orchpay.in
- https://admin.moneyone.co.in
- https://partner.moneyone.co.in

---

## Certificate Renewal

Your Let's Encrypt certificate expires: **May 23, 2026** (80 days)

**To renew:**
1. On EC2: `sudo certbot renew`
2. Re-run: `bash extract_certificates_for_aws.sh`
3. AWS ACM → Select certificate → **"Reimport"**
4. Paste new certificates
5. Done! (ALB automatically uses updated certificate)

**Or:** Set up automatic renewal with certbot hooks to update ACM automatically.
