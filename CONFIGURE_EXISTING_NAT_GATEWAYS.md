# Configure Existing NAT Gateways - Quick Setup

## Current Situation

✅ You already have 2 NAT Gateways created:
- `moneyone-vpc-nat-public1-ap-south-1a` (in public subnet 1a)
- `moneyone-vpc-nat-public2-ap-south-1b` (in public subnet 1b)

✅ You have proper subnet structure:
- 2 Public subnets
- 2 Private subnets

**Problem:** Your NAT Gateways likely have different Elastic IPs, but you need all traffic to use your ONE whitelisted Elastic IP.

---

## Solution Options

### Option 1: Use Single NAT Gateway (Recommended for Cost)

Use only ONE NAT Gateway with your whitelisted Elastic IP. This is cheaper and simpler.

**Cost:** ~₹4,000-6,000/month for 1 NAT Gateway

### Option 2: Keep Both NAT Gateways (High Availability)

Keep both NAT Gateways but you'll need to whitelist BOTH Elastic IPs.

**Cost:** ~₹8,000-12,000/month for 2 NAT Gateways

---

## Recommended: Option 1 - Single NAT Gateway Setup

### Step 1: Check Current NAT Gateway Configuration

1. Go to **VPC Console** → **NAT Gateways**
2. Click on each NAT Gateway
3. Note down which Elastic IPs they're using

### Step 2: Identify Your Whitelisted Elastic IP

1. Go to **EC2 Console** → **Elastic IPs**
2. Find your whitelisted IP
3. Check if it's:
   - Already attached to a NAT Gateway → Great! Use that one
   - Attached to an EC2 instance → Need to move it
   - Not attached → Need to attach it

### Step 3: Delete One NAT Gateway (Keep the one in AZ-1a)

Since you have 2 NAT Gateways and only need 1:

1. Go to **VPC Console** → **NAT Gateways**
2. Select: `moneyone-vpc-nat-public2-ap-south-1b`
3. **Actions** → **Delete NAT gateway**
4. Type "delete" to confirm
5. Click **Delete**

**Note:** Keep the one in `public1-ap-south-1a` as it's your primary AZ.

### Step 4: Attach Your Whitelisted Elastic IP

**Important:** You CANNOT change the Elastic IP of an existing NAT Gateway. You need to:

#### Option A: If NAT Gateway already has your whitelisted IP
- Skip to Step 5 ✅

#### Option B: If NAT Gateway has a different IP

1. **Delete the remaining NAT Gateway:**
   - Select `moneyone-vpc-nat-public1-ap-south-1a`
   - Actions → Delete NAT gateway
   - Confirm deletion

2. **Disassociate your whitelisted Elastic IP** (if attached to instance):
   - Go to EC2 → Elastic IPs
   - Select your whitelisted IP
   - Actions → Disassociate Elastic IP address

3. **Create new NAT Gateway with your Elastic IP:**
   - Go to VPC → NAT Gateways → Create NAT gateway
   - Name: `moneyone-nat-gateway-main`
   - Subnet: `moneyone-vpc-subnet-public1-ap-south-1a`
   - Connectivity type: Public
   - Elastic IP: Select your whitelisted IP
   - Click **Create NAT gateway**
   - Wait 2-3 minutes for "Available" status

### Step 5: Update Route Tables

#### 5.1 Find Your Route Tables

1. Go to **VPC Console** → **Route Tables**
2. You should see multiple route tables

#### 5.2 Update Private Route Table(s)

For EACH private route table:

1. Select the route table
2. Check **Subnet associations** tab
3. If it's associated with private subnets, update it:
   - Go to **Routes** tab
   - Click **Edit routes**
   - Find the route with destination `0.0.0.0/0`
   - Change Target to: `nat-xxxxx` (your remaining NAT Gateway)
   - Click **Save changes**

**Important:** Both private subnets should route through the SAME NAT Gateway now.

#### 5.3 Verify Route Configuration

Your route tables should look like this:

**Public Route Table:**
```
Destination       Target
0.0.0.0/0        igw-xxxxx (Internet Gateway)
10.0.0.0/16      local

Associated Subnets:
- moneyone-vpc-subnet-public1-ap-south-1a
- moneyone-vpc-subnet-public2-ap-south-1b
```

**Private Route Table:**
```
Destination       Target
0.0.0.0/0        nat-xxxxx (Your NAT Gateway with whitelisted IP)
10.0.0.0/16      local

Associated Subnets:
- moneyone-vpc-subnet-private1-ap-south-1a
- moneyone-vpc-subnet-private2-ap-south-1b
```

---

## Step 6: Update Auto Scaling Group

### 6.1 Update Launch Template

1. Go to **EC2 Console** → **Launch Templates**
2. Find your ASG launch template
3. Select it → **Actions** → **Modify template (Create new version)**
4. Scroll to **Network settings**
5. **Auto-assign public IP**: Change to **Disable**
6. Click **Create template version**

### 6.2 Update Auto Scaling Group

1. Go to **EC2 Console** → **Auto Scaling Groups**
2. Select your ASG
3. Click **Edit**
4. Under **Network**:
   - **Subnets**: Select ONLY private subnets:
     - ✅ `moneyone-vpc-subnet-private1-ap-south-1a`
     - ✅ `moneyone-vpc-subnet-private2-ap-south-1b`
     - ❌ Remove any public subnets
5. Under **Launch template**:
   - Update to the new version you created
6. Click **Update**

---

## Step 7: Verify Load Balancer

1. Go to **EC2 Console** → **Load Balancers**
2. Select your ALB
3. Check **Description** tab → **Availability Zones**
4. Ensure it's in PUBLIC subnets:
   - ✅ `moneyone-vpc-subnet-public1-ap-south-1a`
   - ✅ `moneyone-vpc-subnet-public2-ap-south-1b`

If not:
- Actions → Edit subnets
- Select only public subnets
- Save

---

## Step 8: Terminate Old Instances

1. Go to **EC2 Console** → **Auto Scaling Groups**
2. Select your ASG
3. **Instance management** tab
4. Select all running instances
5. **Actions** → **Set to Standby** (or terminate)
6. Wait for ASG to launch new instances in private subnets

---

## Step 9: Verify Everything Works

### 9.1 Check New Instances

1. Go to **EC2 Console** → **Instances**
2. Find new instances launched by ASG
3. Verify:
   - ✅ Subnet is private (private1 or private2)
   - ✅ No public IPv4 address
   - ✅ Status is "Running"

### 9.2 Test Outbound IP

Connect via Session Manager:

1. Select instance → **Connect** → **Session Manager**
2. Run:
```bash
# Check outbound IP
curl ifconfig.me

# Should return your whitelisted Elastic IP!
```

### 9.3 Test Application

```bash
# Test ALB
curl https://your-domain.com/health

# Should work normally
```

---

## Quick Commands to Verify

```bash
# SSH into instance (via Session Manager)
# Then run:

# 1. Check outbound IP
curl ifconfig.me
curl ipinfo.io/ip

# 2. Test internet connectivity
ping -c 3 8.8.8.8
curl -I https://google.com

# 3. Test external API
curl -I https://api.example.com

# All should work and use your whitelisted IP
```

---

## Troubleshooting

### Issue: NAT Gateway shows different IP

**Check which Elastic IP is attached:**
1. VPC Console → NAT Gateways
2. Select your NAT Gateway
3. Check "Elastic IP address" field
4. If wrong, you need to recreate NAT Gateway with correct IP

### Issue: Can't delete NAT Gateway

**Error:** "NAT Gateway is in use"

**Solution:**
1. First update route tables to remove references
2. Wait 2-3 minutes
3. Try deleting again

### Issue: Instances still getting public IPs

**Check:**
1. Launch template has "Auto-assign public IP" = Disabled
2. ASG is using the new launch template version
3. Terminate old instances and let ASG create new ones

### Issue: Application not accessible

**Check:**
1. ALB is in public subnets ✅
2. ALB security group allows inbound 80/443 ✅
3. Target group shows healthy instances ✅
4. Instance security group allows traffic from ALB ✅

---

## Cost Comparison

**Current Setup (2 NAT Gateways):**
- 2 × ₹2,700/month = ₹5,400/month
- Data processing: ₹3.5/GB
- **Total: ₹8,000-12,000/month**

**After Optimization (1 NAT Gateway):**
- 1 × ₹2,700/month = ₹2,700/month
- Data processing: ₹3.5/GB
- **Total: ₹4,000-6,000/month**

**Savings: ~₹4,000-6,000/month** 💰

---

## Alternative: Keep Both NAT Gateways (High Availability)

If you want redundancy:

1. Keep both NAT Gateways
2. Each will have its own Elastic IP
3. You need to whitelist BOTH IPs everywhere
4. Create separate route tables:
   - Private subnet 1a → NAT Gateway 1a
   - Private subnet 1b → NAT Gateway 1b

**Pros:** High availability (if one AZ fails, other works)
**Cons:** Double cost + need to whitelist 2 IPs

---

## Final Checklist

After setup:

- [ ] Only 1 NAT Gateway running (or 2 if HA setup)
- [ ] NAT Gateway has your whitelisted Elastic IP
- [ ] Private route table routes to NAT Gateway
- [ ] ASG launch template disables public IP
- [ ] ASG uses only private subnets
- [ ] ALB uses only public subnets
- [ ] New instances have no public IP
- [ ] `curl ifconfig.me` returns whitelisted IP
- [ ] Application works via ALB
- [ ] External APIs accessible

---

## Summary

Since you already have NAT Gateways:

1. ✅ Delete one NAT Gateway (keep one for cost savings)
2. ✅ Ensure remaining NAT Gateway has your whitelisted Elastic IP
   - If not, recreate it with correct IP
3. ✅ Update private route tables to use this NAT Gateway
4. ✅ Update ASG to use private subnets
5. ✅ Verify all traffic uses whitelisted IP

**Result:** All Auto Scaling instances use the same whitelisted IP! 🎉
