# Complete Beginner's Guide: NAT Gateway Setup
## For IP 13.234.15.221 with Auto Scaling

---

## What You Have Now

- ✅ Main instance: c7i.large
- ✅ Elastic IP: **13.234.15.221** (whitelisted everywhere)
- ✅ Load Balancer (ALB)
- ✅ Auto Scaling Group
- ✅ 2 Availability Zones: ap-south-1a & ap-south-1b
- ✅ Default VPC

## The Problem

When Auto Scaling creates new instances, each gets a different IP address. But your services only whitelist **13.234.15.221**.

## The Solution

Set up NAT Gateway with your Elastic IP so ALL instances use the same IP (13.234.15.221) for outbound traffic.

---

## ⚠️ IMPORTANT: Before You Start

**DO THIS DURING LOW TRAFFIC TIME** (like 2 AM - 5 AM)

**Backup Plan:** Keep your main instance running until everything is verified.

**Time Required:** 30-45 minutes

**Cost:** ~₹4,000-6,000/month for NAT Gateway

---

## PART 1: Prepare Your Elastic IP

### Step 1: Find Your Elastic IP

1. Open AWS Console: https://console.aws.amazon.com
2. Make sure region is **Asia Pacific (Mumbai) ap-south-1** (top right)
3. Click **Services** → **EC2**
4. In left sidebar, scroll down and click **Elastic IPs**
5. Find IP **13.234.15.221**
6. Click on it to see details
7. **Write down** the **Allocation ID** (looks like `eipalloc-0123456789abcdef`)

### Step 2: Disassociate Elastic IP from Main Instance

**⚠️ WARNING:** Your main instance will lose this IP temporarily. Make sure Load Balancer is handling traffic!

1. Still on Elastic IPs page
2. Select the checkbox next to **13.234.15.221**
3. Click **Actions** button (top right)
4. Click **Disassociate Elastic IP address**
5. A popup appears → Click **Disassociate**
6. Status will change to "Not associated" ✅

**Don't worry!** We'll attach it to NAT Gateway next.

---

## PART 2: Create Subnets (Public & Private)

### Step 3: Go to VPC Console

1. Click **Services** → **VPC**
2. In left sidebar, click **Subnets**

### Step 4: Check Your Current Subnets

You should see subnets listed. We need to identify or create:
- 2 Public subnets (for NAT Gateway & Load Balancer)
- 2 Private subnets (for your EC2 instances)

**If you already have subnets named like:**
- `public-subnet-1a` and `public-subnet-1b` → Great! Skip to Step 7
- `private-subnet-1a` and `private-subnet-1b` → Great! Skip to Step 7

**If NOT, continue to create them:**

### Step 5: Create Public Subnets

#### Create Public Subnet 1:

1. Click **Create subnet** (orange button, top right)
2. Fill in:
   ```
   VPC ID: Select your default VPC (vpc-xxxxx)
   Subnet name: public-subnet-1a
   Availability Zone: ap-south-1a
   IPv4 CIDR block: 10.0.1.0/24
   ```
3. Click **Create subnet** (bottom right)

#### Create Public Subnet 2:

1. Click **Create subnet** again
2. Fill in:
   ```
   VPC ID: Select your default VPC (same as above)
   Subnet name: public-subnet-1b
   Availability Zone: ap-south-1b
   IPv4 CIDR block: 10.0.2.0/24
   ```
3. Click **Create subnet**

### Step 6: Create Private Subnets

#### Create Private Subnet 1:

1. Click **Create subnet**
2. Fill in:
   ```
   VPC ID: Select your default VPC
   Subnet name: private-subnet-1a
   Availability Zone: ap-south-1a
   IPv4 CIDR block: 10.0.11.0/24
   ```
3. Click **Create subnet**

#### Create Private Subnet 2:

1. Click **Create subnet**
2. Fill in:
   ```
   VPC ID: Select your default VPC
   Subnet name: private-subnet-1b
   Availability Zone: ap-south-1b
   IPv4 CIDR block: 10.0.12.0/24
   ```
3. Click **Create subnet**

**Now you have 4 subnets!** ✅

---

## PART 3: Create Internet Gateway (if needed)

### Step 7: Check Internet Gateway

1. In VPC Console left sidebar, click **Internet Gateways**
2. Look for an Internet Gateway attached to your VPC
3. **If you see one attached** → Great! Note its ID (igw-xxxxx) and skip to Step 9
4. **If NOT attached or doesn't exist** → Continue to Step 8

### Step 8: Create & Attach Internet Gateway

1. Click **Create internet gateway**
2. Name: `main-internet-gateway`
3. Click **Create internet gateway**
4. After creation, you'll see a green banner
5. Click **Actions** → **Attach to VPC**
6. Select your VPC from dropdown
7. Click **Attach internet gateway**

**Internet Gateway is ready!** ✅

---

## PART 4: Create NAT Gateway with Your Elastic IP

### Step 9: Create NAT Gateway

1. In VPC Console left sidebar, click **NAT Gateways**
2. Click **Create NAT gateway** (orange button)
3. Fill in:
   ```
   Name: main-nat-gateway
   Subnet: Select "public-subnet-1a" (MUST be public subnet!)
   Connectivity type: Public (should be selected by default)
   Elastic IP allocation ID: Click dropdown → Select your IP 13.234.15.221
   ```
4. Click **Create NAT gateway** (bottom right)
5. You'll see a success message
6. **Wait 2-3 minutes** for Status to change from "Pending" to "Available"
7. Refresh the page to check status

**NAT Gateway is ready!** ✅

---

## PART 5: Configure Route Tables

### Step 10: Create Public Route Table

1. In VPC Console left sidebar, click **Route Tables**
2. Click **Create route table**
3. Fill in:
   ```
   Name: public-route-table
   VPC: Select your default VPC
   ```
4. Click **Create route table**

### Step 11: Add Internet Gateway Route to Public Route Table

1. Select **public-route-table** (checkbox)
2. Bottom panel appears → Click **Routes** tab
3. Click **Edit routes**
4. Click **Add route**
5. Fill in:
   ```
   Destination: 0.0.0.0/0
   Target: Click dropdown → Select "Internet Gateway" → Select your igw-xxxxx
   ```
6. Click **Save changes**

### Step 12: Associate Public Subnets

1. Still on **public-route-table** (selected)
2. Click **Subnet associations** tab (bottom panel)
3. Click **Edit subnet associations**
4. Check the boxes for:
   - ✅ public-subnet-1a
   - ✅ public-subnet-1b
5. Click **Save associations**

### Step 13: Create Private Route Table

1. Click **Create route table**
2. Fill in:
   ```
   Name: private-route-table
   VPC: Select your default VPC
   ```
3. Click **Create route table**

### Step 14: Add NAT Gateway Route to Private Route Table

1. Select **private-route-table** (checkbox)
2. Click **Routes** tab (bottom panel)
3. Click **Edit routes**
4. Click **Add route**
5. Fill in:
   ```
   Destination: 0.0.0.0/0
   Target: Click dropdown → Select "NAT Gateway" → Select "main-nat-gateway"
   ```
6. Click **Save changes**

### Step 15: Associate Private Subnets

1. Still on **private-route-table** (selected)
2. Click **Subnet associations** tab
3. Click **Edit subnet associations**
4. Check the boxes for:
   - ✅ private-subnet-1a
   - ✅ private-subnet-1b
5. Click **Save associations**

**Route tables configured!** ✅

---

## PART 6: Update Load Balancer

### Step 16: Move Load Balancer to Public Subnets

1. Click **Services** → **EC2**
2. In left sidebar, scroll down to **Load Balancers**
3. Click on your Load Balancer
4. Click **Actions** → **Edit subnets**
5. **Uncheck** any private subnets
6. **Check** only:
   - ✅ public-subnet-1a
   - ✅ public-subnet-1b
7. Click **Save changes**

**Load Balancer is in public subnets!** ✅

---

## PART 7: Update Auto Scaling Group

### Step 17: Update Launch Template

1. In EC2 Console left sidebar, click **Launch Templates**
2. Find your launch template (used by Auto Scaling)
3. Select it (checkbox)
4. Click **Actions** → **Modify template (Create new version)**
5. Scroll down to **Network settings** section
6. Find **Auto-assign public IP**
7. Change to: **Disable**
8. Scroll to bottom → Click **Create template version**
9. You'll see "Successfully created version X"

### Step 18: Update Auto Scaling Group

1. In EC2 Console left sidebar, click **Auto Scaling Groups**
2. Click on your Auto Scaling Group name
3. Click **Edit** button (top right)
4. Scroll to **Network** section
5. Under **Subnets**:
   - **Remove** any public subnets (uncheck them)
   - **Check** only:
     - ✅ private-subnet-1a
     - ✅ private-subnet-1b
6. Scroll to **Launch template** section
7. Click **Version** dropdown → Select **Latest** (or the version you just created)
8. Scroll to bottom → Click **Update**

**Auto Scaling Group updated!** ✅

---

## PART 8: Replace Old Instances

### Step 19: Terminate Old Instances

**⚠️ IMPORTANT:** This will cause brief downtime for those instances. Load Balancer will route traffic to healthy instances.

1. Still in Auto Scaling Groups page
2. Click on your Auto Scaling Group
3. Click **Instance management** tab
4. You'll see running instances
5. Select all instances (checkboxes)
6. Click **Actions** → **Set to Standby**
7. Confirm by clicking **Set to Standby**
8. Wait 1 minute
9. Select them again → **Actions** → **Terminate instance**
10. Confirm termination

### Step 20: Wait for New Instances

1. Auto Scaling will automatically launch new instances
2. Wait 3-5 minutes
3. Refresh the page
4. You should see new instances launching in **private subnets**
5. Wait until they show "InService" status

**New instances are running!** ✅

---

## PART 9: Verify Everything Works

### Step 21: Check Instance Details

1. Go to **EC2** → **Instances**
2. Find your new instances (launched by Auto Scaling)
3. Click on one instance
4. In **Details** tab, verify:
   - ✅ **Subnet**: Should be private-subnet-1a or private-subnet-1b
   - ✅ **Public IPv4 address**: Should be empty (dash -)
   - ✅ **Private IPv4 address**: Should have an IP like 10.0.11.x

### Step 22: Test Outbound IP

1. Select one of your new instances
2. Click **Connect** button (top right)
3. Click **Session Manager** tab
4. Click **Connect** button
5. A terminal window opens
6. Type this command and press Enter:
```bash
curl ifconfig.me
```
7. **You should see: 13.234.15.221** ✅

If you see your whitelisted IP, SUCCESS! 🎉

### Step 23: Test Your Application

1. Open your application URL (through Load Balancer)
2. Test all features
3. Check if external API calls work
4. Everything should work normally

---

## PART 10: Verify Load Balancer Health

### Step 24: Check Target Group

1. Go to **EC2** → **Target Groups** (left sidebar)
2. Click on your target group
3. Click **Targets** tab
4. All instances should show **healthy** status
5. If any show "unhealthy", wait 2-3 minutes and refresh

**If all healthy, you're done!** ✅

---

## Troubleshooting

### Problem 1: Can't connect to instance

**Solution:** Use Session Manager (not SSH)
1. EC2 → Instances → Select instance
2. Connect → Session Manager → Connect

### Problem 2: Instance shows wrong IP

**Check:**
```bash
# In Session Manager terminal
curl ifconfig.me
```

If NOT showing 13.234.15.221:
1. Check NAT Gateway has your Elastic IP attached
2. Check private route table routes to NAT Gateway
3. Check instance is in private subnet

### Problem 3: Application not accessible

**Check:**
1. Load Balancer is in public subnets ✅
2. Target group shows healthy instances ✅
3. Security groups allow traffic ✅

### Problem 4: NAT Gateway not working

**Check:**
1. VPC Console → NAT Gateways
2. Status should be "Available"
3. Elastic IP should be 13.234.15.221
4. Subnet should be public-subnet-1a

---

## Quick Verification Commands

Connect to instance via Session Manager and run:

```bash
# Check outbound IP (should be 13.234.15.221)
curl ifconfig.me

# Test internet connectivity
ping -c 3 8.8.8.8

# Test DNS resolution
nslookup google.com

# Test HTTPS
curl -I https://google.com

# All should work!
```

---

## Cost Breakdown

**NAT Gateway:**
- Hourly: ₹3.24/hour
- Monthly: ₹2,332/month
- Data transfer: ₹3.24/GB

**Total estimated: ₹4,000-6,000/month**

---

## Final Checklist

After completing all steps:

- [ ] Elastic IP 13.234.15.221 attached to NAT Gateway
- [ ] NAT Gateway status is "Available"
- [ ] Public route table routes to Internet Gateway
- [ ] Private route table routes to NAT Gateway
- [ ] Load Balancer in public subnets
- [ ] Auto Scaling Group uses private subnets
- [ ] Launch template has "Auto-assign public IP" disabled
- [ ] New instances have no public IP
- [ ] `curl ifconfig.me` returns 13.234.15.221
- [ ] Application works through Load Balancer
- [ ] All target group instances are healthy

---

## What You Achieved

✅ All Auto Scaling instances now use IP **13.234.15.221** for outbound traffic
✅ No more IP whitelist issues
✅ Instances are secure in private subnets
✅ Load Balancer handles all inbound traffic
✅ Auto Scaling works seamlessly

---

## Rollback (If Something Goes Wrong)

If you need to undo everything:

1. **Re-attach Elastic IP to main instance:**
   - EC2 → Elastic IPs → Select 13.234.15.221
   - Actions → Associate Elastic IP address
   - Select your main instance → Associate

2. **Update Auto Scaling Group:**
   - Use old launch template version
   - Change subnets back to original

3. **Delete NAT Gateway:**
   - VPC → NAT Gateways → Select → Actions → Delete

4. **Keep old instances running** until verified

---

## Need Help?

If stuck at any step:

1. Check AWS Console for error messages
2. Verify region is ap-south-1 (Mumbai)
3. Make sure you have proper IAM permissions
4. Check VPC is the default VPC
5. Verify all resources are in same VPC

---

## Summary

You've successfully set up NAT Gateway! Now:
- All instances use the same whitelisted IP (13.234.15.221)
- Auto Scaling works without IP issues
- Your application is more secure
- External services see consistent IP

**Congratulations!** 🎉
