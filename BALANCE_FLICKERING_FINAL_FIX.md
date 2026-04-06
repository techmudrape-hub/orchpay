# Balance Flickering - Final Fix Guide

## Your Current Situation

You have:
- ✅ Load Balancer (ALB)
- ✅ Auto Scaling Group with multiple instances
- ❌ Not all instances have the updated code
- ❌ Balance shows different values on refresh

## Why This Happens

```
User Request 1 → ALB → Instance A (new code) → Balance: ₹1,101.13 ✅
User Request 2 → ALB → Instance B (old code) → Balance: ₹999.88 ❌
User Request 3 → ALB → Instance A (new code) → Balance: ₹1,101.13 ✅
```

## Solution: 3-Step Fix (15 Minutes)

### Step 1: Enable Sticky Sessions (Immediate Relief - 2 Minutes)

This makes sure each user always hits the same instance:

**AWS Console Method:**
1. Go to: AWS Console → EC2 → Load Balancers
2. Select your Application Load Balancer
3. Click "Target Groups" tab at bottom
4. Select your target group (e.g., `moneyone-backend-tg`)
5. Click "Actions" → "Edit attributes"
6. Scroll to "Stickiness" section
7. ✅ Check "Enable stickiness"
8. Select "Load balancer generated cookie"
9. Duration: `86400` seconds (24 hours)
10. Click "Save changes"

**Result:** Users will now consistently see the same balance (from whichever instance they hit first)

### Step 2: Find All Your Backend Instances (3 Minutes)

Run this command to see all instances:

```bash
# Get all instances in your Auto Scaling Group
aws ec2 describe-instances \
  --region ap-south-1 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Or check in AWS Console:
1. EC2 → Auto Scaling Groups
2. Select your ASG
3. Click "Instance management" tab
4. Note all instance IPs

### Step 3: Deploy to ALL Instances (10 Minutes)

Create and run this script:

```bash
#!/bin/bash
# deploy_balance_fix_all_instances.sh

# REPLACE THESE WITH YOUR ACTUAL INSTANCE IPs
INSTANCES=(
  "13.232.xxx.xxx"
  "13.232.yyy.yyy"
  "13.232.zzz.zzz"
)

echo "=========================================="
echo "Deploying Balance Fix to All Instances"
echo "=========================================="
echo ""

for instance in "${INSTANCES[@]}"; do
  echo "📦 Deploying to: $instance"
  echo "----------------------------------------"
  
  ssh -o StrictHostKeyChecking=no ubuntu@$instance << 'EOF'
    cd /home/ubuntu/moneyone_backend/backend
    
    # Backup current files
    echo "Creating backups..."
    cp database.py database.py.backup.$(date +%Y%m%d_%H%M%S)
    cp wallet_routes.py wallet_routes.py.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    cp payout_routes.py payout_routes.py.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    
    # Pull latest code
    echo "Pulling latest code..."
    git pull origin main || echo "Git pull failed, continuing..."
    
    # Restart service
    echo "Restarting backend service..."
    sudo systemctl restart moneyone-backend
    
    # Wait for service to start
    sleep 3
    
    # Check status
    if sudo systemctl is-active --quiet moneyone-backend; then
      echo "✅ Service running successfully"
    else
      echo "❌ Service failed to start"
      sudo journalctl -u moneyone-backend -n 20 --no-pager
    fi
EOF
  
  if [ $? -eq 0 ]; then
    echo "✅ Successfully deployed to $instance"
  else
    echo "❌ Failed to deploy to $instance"
  fi
  echo ""
done

echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "Next: Test balance consistency"
```

Save and run:
```bash
chmod +x deploy_balance_fix_all_instances.sh
./deploy_balance_fix_all_instances.sh
```

## Verification (2 Minutes)

Test that balance is now consistent:

```bash
# Test 10 times - should show same balance every time
for i in {1..10}; do
  echo "Test $i:"
  curl -s https://api.orchpay.in/wallet/overview \
    -H "Authorization: Bearer YOUR_TOKEN" | jq '.data.balance'
  sleep 1
done
```

**Expected Result:** Same balance on all 10 requests ✅

## About Auto Scaling

### Should You Disable Auto Scaling?

**NO - Don't disable it yet.** Here's why:

1. **Auto Scaling is good** - it helps handle traffic spikes
2. **The problem isn't Auto Scaling** - it's that instances have different code
3. **Fix the root cause first** - deploy to all instances

### After Fixing, Update Your Launch Template

So new instances automatically get the correct code:

```bash
# Option 1: Update Launch Template User Data
aws ec2 modify-launch-template \
  --launch-template-id lt-xxxxx \
  --default-version '$Latest' \
  --launch-template-data '{
    "UserData": "BASE64_ENCODED_STARTUP_SCRIPT"
  }'

# Option 2: Create New AMI with Updated Code
# 1. SSH to one working instance
# 2. Create AMI: EC2 → Instances → Actions → Image → Create Image
# 3. Update Launch Template to use new AMI
# 4. Refresh instances in ASG
```

## If Balance Still Flickers After Fix

### Check 1: Verify All Instances Updated

```bash
# Check code version on each instance
for instance in instance1_ip instance2_ip instance3_ip; do
  echo "Checking $instance..."
  ssh ubuntu@$instance "md5sum /home/ubuntu/moneyone_backend/backend/database.py"
done

# All MD5 hashes should be IDENTICAL
```

### Check 2: Verify Sticky Sessions Enabled

```bash
# Check target group attributes
aws elbv2 describe-target-group-attributes \
  --region ap-south-1 \
  --target-group-arn YOUR_TARGET_GROUP_ARN | grep stickiness
```

Should show:
```json
{
  "Key": "stickiness.enabled",
  "Value": "true"
}
```

### Check 3: Clear Browser Cache

Sometimes browser caches old responses:
- Press Ctrl+Shift+R (hard refresh)
- Or open in Incognito mode

## Long-Term Solution: CI/CD Pipeline

To prevent this in future, set up automated deployment:

1. **CodeDeploy** - Automatically deploys to all instances
2. **Blue-Green Deployment** - Zero downtime updates
3. **Rolling Updates** - Update instances one by one

For now, the 3-step fix above will solve your immediate problem.

## Summary

✅ **Step 1:** Enable sticky sessions (2 min) - Immediate relief
✅ **Step 2:** Find all instances (3 min) - Know what to update
✅ **Step 3:** Deploy to all instances (10 min) - Permanent fix

**Total Time:** 15 minutes
**Result:** Consistent balance across all requests

## Need Help?

If you're still seeing flickering after following all steps:
1. Share the output of the deployment script
2. Share the output of the verification test
3. Check: `sudo journalctl -u moneyone-backend -n 50` on each instance
