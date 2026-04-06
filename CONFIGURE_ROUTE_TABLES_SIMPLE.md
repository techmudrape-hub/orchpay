# Configure Route Tables - Simple Steps

## What You Need to Do

You need to set up 2 route tables for your VPC (`vpc-08fa75632e93da39b`):
1. Public route table (for NAT Gateway & Load Balancer)
2. Private route table (for EC2 instances)

---

## Step 1: Identify or Create Public Route Table

### Option A: Use Existing Main Route Table

1. In Route Tables page, look for a route table with:
   - VPC: `vpc-08fa75632e93da39b`
   - Main: Yes

2. Click on it to select
3. Look at **Routes** tab
4. Check if it has a route to Internet Gateway (`igw-00b8c47971ac1f90a`)

**If YES:** Use this as your public route table, rename it to `public-route-table`

**If NO:** Continue to Option B

### Option B: Create New Public Route Table

1. Click **Create route table**
2. Fill in:
   ```
   Name: public-route-table
   VPC: vpc-08fa75632e93da39b
   ```
3. Click **Create route table**

---

## Step 2: Configure Public Route Table

1. Select **public-route-table** (checkbox)
2. Click **Routes** tab (bottom panel)
3. Click **Edit routes**
4. Check if route `0.0.0.0/0` exists:
   - **If YES:** Make sure Target is `igw-00b8c47971ac1f90a`
   - **If NO:** Click **Add route** and add:
     ```
     Destination: 0.0.0.0/0
     Target: Internet Gateway → igw-00b8c47971ac1f90a
     ```
5. Click **Save changes**

---

## Step 3: Associate Public Subnets

1. Still on **public-route-table**
2. Click **Subnet associations** tab
3. Click **Edit subnet associations**
4. Check these boxes:
   - ✅ Find subnet with CIDR `172.31.0.0/20` (should be in ap-south-1a)
   - ✅ Find subnet with CIDR `172.31.16.0/20` (should be in ap-south-1b)
   
   OR if you renamed them:
   - ✅ `public-subnet-1a`
   - ✅ `public-subnet-1b`

5. Click **Save associations**

---

## Step 4: Create Private Route Table

1. Click **Create route table**
2. Fill in:
   ```
   Name: private-route-table
   VPC: vpc-08fa75632e93da39b
   ```
3. Click **Create route table**

---

## Step 5: Configure Private Route Table

1. Select **private-route-table** (checkbox)
2. Click **Routes** tab
3. Click **Edit routes**
4. Click **Add route**
5. Fill in:
   ```
   Destination: 0.0.0.0/0
   Target: NAT Gateway → nat-12d77c4794a714bb2
   ```
6. Click **Save changes**

---

## Step 6: Associate Private Subnets

1. Still on **private-route-table**
2. Click **Subnet associations** tab
3. Click **Edit subnet associations**
4. Check these boxes:
   - ✅ `private-subnet-1a` (172.31.48.0/20)
   - ✅ `private-subnet-1b` (172.31.64.0/20)
5. Click **Save associations**

---

## Verification

After completing all steps, you should have:

**Public Route Table:**
```
Name: public-route-table
VPC: vpc-08fa75632e93da39b
Routes:
  - 0.0.0.0/0 → igw-00b8c47971ac1f90a
  - 172.31.0.0/16 → local
Subnets:
  - 172.31.0.0/20 (ap-south-1a)
  - 172.31.16.0/20 (ap-south-1b)
```

**Private Route Table:**
```
Name: private-route-table
VPC: vpc-08fa75632e93da39b
Routes:
  - 0.0.0.0/0 → nat-12d77c4794a714bb2
  - 172.31.0.0/16 → local
Subnets:
  - private-subnet-1a (172.31.48.0/20)
  - private-subnet-1b (172.31.64.0/20)
```

---

## Next Steps

After route tables are configured, continue with:
- Step 7: Update Load Balancer
- Step 8: Update Auto Scaling Group

Follow the guide: `SIMPLE_NAT_GATEWAY_YOUR_SETUP.md`

---

## Quick Reference

**Your Resources:**
- VPC: `vpc-08fa75632e93da39b`
- Internet Gateway: `igw-00b8c47971ac1f90a`
- NAT Gateway: `nat-12d77c4794a714bb2`
- Elastic IP: `13.234.15.221`

**Public Subnets (existing):**
- 172.31.0.0/20 (ap-south-1a)
- 172.31.16.0/20 (ap-south-1b)

**Private Subnets (newly created):**
- private-subnet-1a: 172.31.48.0/20
- private-subnet-1b: 172.31.64.0/20
