# Complete Process: Fix Admin Captcha Issue with Multi-Instance Setup

## Step 1: Scale Down to 1 Instance

1. Go to **AWS Console** → **EC2** → **Auto Scaling Groups**
2. Click on your Auto Scaling Group name
3. Click **Edit** button (top right)
4. Change these values:
   - **Desired capacity**: 1
   - **Minimum capacity**: 1
   - **Maximum capacity**: 1
5. Click **Update**
6. Wait 2-3 minutes - one instance will terminate automatically
7. Verify: Go to **EC2** → **Instances** - you should see only 1 running instance

---

## Step 2: Test Admin Login

1. Go to https://admin.moneyone.co.in
2. Press **Ctrl + Shift + R** (hard refresh to clear cache)
3. Try logging in with your admin credentials
4. **It should work now!** ✅

---

## Step 3: Deploy Frontend Changes (Remove Captcha UI)

Now that backend is working, let's update the frontend to remove the captcha UI completely.

### On your EC2 instance:

```bash
# SSH to your instance
ssh ubuntu@your-ec2-ip

# Navigate to project directory
cd /var/www/moneyone/moneyone

# Backup current files
sudo cp moneyone_admin/src/pages/Login.jsx moneyone_admin/src/pages/Login.jsx.backup
sudo cp moneyone_admin/src/api/admin_api.js moneyone_admin/src/api/admin_api.js.backup
```

### From your local machine, upload the updated files:

```bash
# Upload updated Login page
scp moneyone_admin/src/pages/Login.jsx ubuntu@your-ec2-ip:/tmp/

# Upload updated API file
scp moneyone_admin/src/api/admin_api.js ubuntu@your-ec2-ip:/tmp/
```

### Back on EC2, move files and rebuild:

```bash
# Move files to correct location
sudo mv /tmp/Login.jsx /var/www/moneyone/moneyone/moneyone_admin/src/pages/
sudo mv /tmp/admin_api.js /var/www/moneyone/moneyone/moneyone_admin/src/api/

# Set permissions
sudo chown -R ubuntu:ubuntu /var/www/moneyone/moneyone/moneyone_admin/src/

# Build frontend
cd /var/www/moneyone/moneyone/moneyone_admin
npm run build
```

---

## Step 4: Test Updated Frontend

1. Go to https://admin.moneyone.co.in
2. Press **Ctrl + Shift + R** (hard refresh)
3. You should now see a cleaner login form with:
   - ✅ Admin ID field
   - ✅ Password field
   - ❌ NO captcha field (removed!)
4. Login should work perfectly

---

## Step 5: Create New AMI with Updated Code

1. Go to **AWS Console** → **EC2** → **Instances**
2. Select your running instance
3. Click **Actions** → **Image and templates** → **Create image**
4. Fill in:
   - **Image name**: `moneyone-backend-v3-no-captcha`
   - **Image description**: `Backend with captcha removed, supports multi-instance`
5. Click **Create image**
6. Wait 5-10 minutes for AMI creation (check under **AMIs** in left menu)

---

## Step 6: Update Launch Template

1. Go to **EC2** → **Launch Templates**
2. Select `moneyone-backend-template`
3. Click **Actions** → **Modify template (Create new version)**
4. In **Application and OS Images (Amazon Machine Image)**:
   - Click **My AMIs**
   - Select your new AMI: `moneyone-backend-v3-no-captcha`
5. Scroll down and click **Create template version**
6. After creation, click **Actions** → **Set default version**
7. Select the new version number
8. Click **Set as default version**

---

## Step 7: Scale Back to 2 Instances

1. Go to **EC2** → **Auto Scaling Groups**
2. Select your Auto Scaling Group
3. Click **Edit**
4. Change values:
   - **Desired capacity**: 2
   - **Minimum capacity**: 1
   - **Maximum capacity**: 4
5. Click **Update**
6. Wait 2-3 minutes - a second instance will launch automatically
7. Both instances will now have the updated code!

---

## Step 8: Final Testing

1. Go to https://admin.moneyone.co.in
2. Login multiple times (to hit different instances)
3. Should work consistently every time ✅
4. No more "Invalid or expired captcha session" errors!

---

## Summary of Changes

### Backend:
- ✅ Removed captcha validation from login endpoint
- ✅ Login accepts captcha fields but ignores them (backward compatible)
- ✅ Works across multiple instances

### Frontend:
- ✅ Removed captcha input field
- ✅ Removed captcha image display
- ✅ Removed captcha refresh button
- ✅ Cleaner, simpler login form

### Infrastructure:
- ✅ New AMI with updated code
- ✅ Launch template updated
- ✅ Can scale to multiple instances without issues

---

## Troubleshooting

**If login still fails after Step 2:**
- Check backend logs: `sudo journalctl -u moneyone-api -f`
- Verify service is running: `sudo systemctl status moneyone-api`
- Check if file was updated: `sudo grep "captcha validation removed" /var/www/moneyone/moneyone/backend/app.py`

**If frontend still shows captcha after Step 4:**
- Clear browser cache completely
- Try incognito/private browsing mode
- Check build completed successfully: `ls -la /var/www/moneyone/moneyone/moneyone_admin/dist/`

**If second instance doesn't work after Step 7:**
- Verify it's using the new AMI
- Check launch template default version is set correctly
- Terminate both instances and let Auto Scaling create fresh ones

---

## Rollback Plan

If anything goes wrong:

**Backend:**
```bash
sudo cp /var/www/moneyone/moneyone/backend/app.py.backup /var/www/moneyone/moneyone/backend/app.py
sudo systemctl restart moneyone-api
```

**Frontend:**
```bash
sudo cp /var/www/moneyone/moneyone/moneyone_admin/src/pages/Login.jsx.backup /var/www/moneyone/moneyone/moneyone_admin/src/pages/Login.jsx
sudo cp /var/www/moneyone/moneyone/moneyone_admin/src/api/admin_api.js.backup /var/www/moneyone/moneyone/moneyone_admin/src/api/admin_api.js
cd /var/www/moneyone/moneyone/moneyone_admin
npm run build
```

**Auto Scaling:**
- Change launch template back to previous version
- Terminate instances to force recreation with old AMI
