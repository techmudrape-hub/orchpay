# AWS VPC Configuration Guide

## What is a VPC?

A Virtual Private Cloud (VPC) is your own isolated network in AWS where you can launch resources like EC2 instances, RDS databases, and load balancers. Think of it as your private data center in the cloud.

---

## Why Configure a VPC?

- **Security**: Isolate your resources from the public internet
- **Control**: Define your own IP address range, subnets, and routing
- **Compliance**: Meet security requirements for production systems
- **Organization**: Separate development, staging, and production environments

---

## VPC Architecture for MoneyOne

```
Internet
    |
Internet Gateway
    |
Public Subnet (ALB, NAT Gateway)
    |
Private Subnet (EC2 Instances, Backend)
    |
Private Subnet (RDS Database)
```

---

## PART 1: Create VPC

### Step 1.1: Login to AWS Console

1. Go to https://console.aws.amazon.com/
2. Navigate to VPC service (search "VPC" in top search bar)
3. Select your region (e.g., ap-south-1 for India)

### Step 1.2: Create VPC

1. Click "Create VPC"
2. Choose "VPC and more" (recommended - creates everything automatically)

**VPC Settings:**
```
Name tag: moneyone-vpc
IPv4 CIDR block: 10.0.0.0/16
IPv6 CIDR block: No IPv6 CIDR block
Tenancy: Default
```

**Availability Zones:**
```
Number of AZs: 2 (for high availability)
```

**Subnets:**
```
Number of public subnets: 2
Number of private subnets: 2
```

**NAT Gateways:**
```
NAT gateways: 1 per AZ (recommended for production)
OR: In 1 AZ (cheaper for testing)
```

**VPC Endpoints:**
```
S3 Gateway: Yes (free, improves performance)
```

3. Click "Create VPC"
4. Wait 2-3 minutes for creation

### Step 1.3: Note Your VPC Details

After creation, note these details:
```
VPC ID: vpc-xxxxxxxxxxxxx
CIDR Block: 10.0.0.0/16
Public Subnet 1: subnet-xxxxx (10.0.0.0/24) - AZ: ap-south-1a
Public Subnet 2: subnet-xxxxx (10.0.1.0/24) - AZ: ap-south-1b
Private Subnet 1: subnet-xxxxx (10.0.128.0/24) - AZ: ap-south-1a
Private Subnet 2: subnet-xxxxx (10.0.129.0/24) - AZ: ap-south-1b
Internet Gateway: igw-xxxxx
NAT Gateway: nat-xxxxx
```

---

## PART 2: Manual VPC Creation (Alternative)

If you prefer step-by-step control:

### Step 2.1: Create VPC

1. VPC Dashboard → Your VPCs → Create VPC
2. Configure:
```
Name: moneyone-vpc
IPv4 CIDR: 10.0.0.0/16
```
3. Click "Create VPC"

### Step 2.2: Create Internet Gateway

1. VPC Dashboard → Internet Gateways → Create internet gateway
2. Name: `moneyone-igw`
3. Click "Create"
4. Select the gateway → Actions → Attach to VPC
5. Select `moneyone-vpc` → Attach

### Step 2.3: Create Subnets

**Public Subnet 1 (for Load Balancer):**
```
Name: moneyone-public-subnet-1a
VPC: moneyone-vpc
Availability Zone: ap-south-1a
IPv4 CIDR: 10.0.0.0/24
```

**Public Subnet 2:**
```
Name: moneyone-public-subnet-1b
VPC: moneyone-vpc
Availability Zone: ap-south-1b
IPv4 CIDR: 10.0.1.0/24
```

**Private Subnet 1 (for EC2 Backend):**
```
Name: moneyone-private-subnet-1a
VPC: moneyone-vpc
Availability Zone: ap-south-1a
IPv4 CIDR: 10.0.128.0/24
```

**Private Subnet 2 (for RDS):**
```
Name: moneyone-private-subnet-1b
VPC: moneyone-vpc
Availability Zone: ap-south-1b
IPv4 CIDR: 10.0.129.0/24
```

### Step 2.4: Create NAT Gateway

1. VPC Dashboard → NAT Gateways → Create NAT gateway
2. Configure:
```
Name: moneyone-nat-gw
Subnet: moneyone-public-subnet-1a (must be public)
Connectivity type: Public
```
3. Click "Allocate Elastic IP" (creates new IP automatically)
4. Click "Create NAT gateway"
5. Wait 5 minutes for "Available" status

### Step 2.5: Create Route Tables

**Public Route Table:**
1. VPC Dashboard → Route Tables → Create route table
2. Name: `moneyone-public-rt`
3. VPC: `moneyone-vpc`
4. Create
5. Select the route table → Routes tab → Edit routes
6. Add route:
   ```
   Destination: 0.0.0.0/0
   Target: Internet Gateway (select moneyone-igw)
   ```
7. Save
8. Subnet associations tab → Edit subnet associations
9. Select both public subnets → Save

**Private Route Table:**
1. Create route table
2. Name: `moneyone-private-rt`
3. VPC: `moneyone-vpc`
4. Create
5. Select → Routes → Edit routes
6. Add route:
   ```
   Destination: 0.0.0.0/0
   Target: NAT Gateway (select moneyone-nat-gw)
   ```
7. Save
8. Subnet associations → Edit
9. Select both private subnets → Save

---

## PART 3: Security Groups Configuration

### Step 3.1: ALB Security Group

1. VPC Dashboard → Security Groups → Create security group
2. Configure:
```
Name: moneyone-alb-sg
Description: Security group for Application Load Balancer
VPC: moneyone-vpc
```

**Inbound Rules:**
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| HTTP | TCP | 80 | 0.0.0.0/0 | Allow HTTP from internet |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Allow HTTPS from internet |

**Outbound Rules:**
| Type | Protocol | Port | Destination | Description |
|------|----------|------|-------------|-------------|
| All traffic | All | All | 0.0.0.0/0 | Allow all outbound |

3. Click "Create security group"

### Step 3.2: EC2 Backend Security Group

1. Create security group
2. Configure:
```
Name: moneyone-backend-sg
Description: Security group for backend EC2 instances
VPC: moneyone-vpc
```

**Inbound Rules:**
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| Custom TCP | TCP | 5000 | moneyone-alb-sg | Allow from ALB |
| SSH | TCP | 22 | My IP | SSH access (your IP only) |

**Outbound Rules:**
| Type | Protocol | Port | Destination | Description |
|------|----------|------|-------------|-------------|
| All traffic | All | All | 0.0.0.0/0 | Allow all outbound |

3. Click "Create security group"

### Step 3.3: RDS Security Group

1. Create security group
2. Configure:
```
Name: moneyone-rds-sg
Description: Security group for RDS database
VPC: moneyone-vpc
```

**Inbound Rules:**
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| MySQL/Aurora | TCP | 3306 | moneyone-backend-sg | Allow from backend only |

**Outbound Rules:**
| Type | Protocol | Port | Destination | Description |
|------|----------|------|-------------|-------------|
| All traffic | All | All | 0.0.0.0/0 | Allow all outbound |

3. Click "Create security group"

---

## PART 4: Launch Resources in VPC

### Step 4.1: Launch EC2 in Private Subnet

1. EC2 Dashboard → Launch Instance
2. Configure:
```
Name: moneyone-backend
AMI: Ubuntu 22.04 LTS
Instance type: t3.medium
Key pair: your-key-pair
```

3. Network settings:
```
VPC: moneyone-vpc
Subnet: moneyone-private-subnet-1a (PRIVATE)
Auto-assign public IP: Disable (important!)
Security group: moneyone-backend-sg
```

4. Launch instance

### Step 4.2: Create RDS in Private Subnet

1. RDS Dashboard → Create database
2. Configure:
```
Engine: MySQL 8.0
Template: Production
DB instance identifier: moneyone-db
Master username: admin
Master password: [strong password]
Instance type: db.t3.medium
```

3. Connectivity:
```
VPC: moneyone-vpc
Subnet group: Create new
  - Name: moneyone-db-subnet-group
  - Subnets: Select both private subnets
Public access: No (important!)
VPC security group: moneyone-rds-sg
```

4. Create database

### Step 4.3: Create Application Load Balancer

1. EC2 Dashboard → Load Balancers → Create
2. Select Application Load Balancer
3. Configure:
```
Name: moneyone-alb
Scheme: Internet-facing
IP address type: IPv4
```

4. Network mapping:
```
VPC: moneyone-vpc
Mappings: Select both public subnets
  - moneyone-public-subnet-1a
  - moneyone-public-subnet-1b
```

5. Security groups:
```
Select: moneyone-alb-sg
```

6. Listeners:
```
Protocol: HTTP
Port: 80
Default action: Forward to target group
```

7. Create load balancer

---

## PART 5: Connect to Private EC2 (Bastion Host Method)

Since your EC2 is in a private subnet, you need a bastion host to access it.

### Option 1: Create Bastion Host

1. Launch small EC2 instance (t3.micro)
2. Configure:
```
Name: moneyone-bastion
Subnet: moneyone-public-subnet-1a (PUBLIC)
Auto-assign public IP: Enable
Security group: Create new
  - Allow SSH (port 22) from My IP only
```

3. SSH to bastion:
```bash
ssh -i your-key.pem ubuntu@bastion-public-ip
```

4. From bastion, SSH to private EC2:
```bash
ssh -i your-key.pem ubuntu@private-ec2-ip
```

### Option 2: Use AWS Systems Manager (Recommended)

No bastion needed, more secure:

1. Attach IAM role to EC2 with `AmazonSSMManagedInstanceCore` policy
2. Install SSM agent (pre-installed on Ubuntu 22.04)
3. Connect via AWS Console:
   - EC2 → Instances → Select instance
   - Connect → Session Manager → Connect

---

## PART 6: VPC Peering (Optional)

Connect multiple VPCs (e.g., dev and prod):

1. VPC Dashboard → Peering Connections → Create
2. Configure:
```
Name: dev-to-prod-peering
VPC (Requester): dev-vpc
VPC (Accepter): prod-vpc
```
3. Create peering connection
4. Accept the request
5. Update route tables in both VPCs

---

## PART 7: VPC Flow Logs (Monitoring)

Track network traffic for security and troubleshooting:

1. VPC Dashboard → Your VPCs → Select moneyone-vpc
2. Flow logs tab → Create flow log
3. Configure:
```
Name: moneyone-vpc-flow-logs
Filter: All (or Reject for security monitoring)
Destination: Send to CloudWatch Logs
Log group: /aws/vpc/moneyone
IAM role: Create new role
```
4. Create flow log

---

## PART 8: Cost Optimization

### NAT Gateway Costs

NAT Gateway is expensive (~$32/month + data transfer):

**Cheaper alternatives:**
1. **Single NAT Gateway**: Use 1 instead of 2 (less redundant)
2. **NAT Instance**: Launch t3.micro as NAT (~$7/month)
3. **VPC Endpoints**: Use for AWS services (S3, DynamoDB) - free

### VPC Endpoints Setup

1. VPC Dashboard → Endpoints → Create endpoint
2. For S3:
```
Service: com.amazonaws.ap-south-1.s3 (Gateway)
VPC: moneyone-vpc
Route tables: Select private route table
```
3. Create endpoint (free!)

---

## PART 9: Troubleshooting

### Issue 1: Can't Access EC2 in Private Subnet

**Solution:**
- Use bastion host or AWS Systems Manager
- Verify NAT Gateway is working
- Check route table has NAT Gateway route

### Issue 2: RDS Connection Timeout

**Solution:**
```bash
# Check security group allows EC2
# Verify both in same VPC
# Test from EC2:
telnet rds-endpoint 3306
```

### Issue 3: ALB Can't Reach EC2

**Solution:**
- Verify EC2 security group allows ALB security group
- Check target group health checks
- Ensure EC2 is in correct subnet

### Issue 4: No Internet from Private Subnet

**Solution:**
- Check NAT Gateway is in public subnet
- Verify NAT Gateway has Elastic IP
- Check private route table points to NAT Gateway
- Verify public route table has Internet Gateway

---

## PART 10: Security Best Practices

### 1. Network ACLs (Additional Layer)

1. VPC Dashboard → Network ACLs
2. Create custom NACL for each subnet
3. Add rules (stateless, both inbound and outbound)

### 2. VPC Endpoints for AWS Services

Use VPC endpoints instead of going through internet:
- S3 endpoint (Gateway - free)
- DynamoDB endpoint (Gateway - free)
- Other services (Interface - paid)

### 3. Enable VPC Flow Logs

Monitor all network traffic for security analysis.

### 4. Use Private Subnets

Keep databases and backend in private subnets always.

### 5. Restrict Security Groups

Only allow necessary ports and sources.

---

## Complete VPC Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                ┌────────▼────────┐
                │ Internet Gateway │
                └────────┬────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                  │
┌───────▼────────┐              ┌─────────▼────────┐
│ Public Subnet  │              │ Public Subnet    │
│ 10.0.0.0/24    │              │ 10.0.1.0/24      │
│ AZ: 1a         │              │ AZ: 1b           │
│                │              │                  │
│ - ALB          │              │ - NAT Gateway    │
│ - Bastion      │              │                  │
└───────┬────────┘              └─────────┬────────┘
        │                                  │
        │         ┌────────────────────────┘
        │         │
┌───────▼─────────▼──────┐     ┌──────────────────┐
│ Private Subnet         │     │ Private Subnet   │
│ 10.0.128.0/24          │     │ 10.0.129.0/24    │
│ AZ: 1a                 │     │ AZ: 1b           │
│                        │     │                  │
│ - EC2 Backend          │     │ - RDS Database   │
│ - Auto Scaling Group   │     │ - Read Replica   │
└────────────────────────┘     └──────────────────┘
```

---

## Quick Reference Commands

### Check VPC Configuration
```bash
# List VPCs
aws ec2 describe-vpcs

# List subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx"

# List route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxx"

# List security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxx"

# Check NAT Gateway
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-xxxxx"
```

### Test Connectivity
```bash
# From EC2, test internet (should work via NAT)
curl -I https://google.com

# Test RDS connection
mysql -h rds-endpoint -u admin -p

# Check routes
ip route show

# Check DNS
nslookup rds-endpoint
```

---

## Cost Summary

**Monthly VPC Costs:**
- VPC itself: Free
- Internet Gateway: Free
- NAT Gateway (1): ~$32 + data transfer
- NAT Gateway (2): ~$64 + data transfer
- VPC Endpoints (Gateway): Free
- VPC Endpoints (Interface): ~$7 each
- Elastic IPs (unused): $3.60 each

**Recommendation for Budget:**
- Use 1 NAT Gateway: $32/month
- Use VPC Gateway Endpoints: Free
- Avoid unused Elastic IPs

---

## Next Steps

After VPC setup:
1. ✅ Launch EC2 instances in private subnets
2. ✅ Create RDS in private subnets
3. ✅ Setup Application Load Balancer in public subnets
4. ✅ Configure security groups properly
5. ✅ Enable VPC Flow Logs
6. ✅ Setup CloudWatch monitoring
7. ✅ Test connectivity and security

---

## Support Checklist

Before asking for help:
- [ ] VPC has Internet Gateway attached
- [ ] Public subnets have route to Internet Gateway
- [ ] Private subnets have route to NAT Gateway
- [ ] NAT Gateway is in public subnet
- [ ] NAT Gateway has Elastic IP
- [ ] Security groups allow necessary traffic
- [ ] Resources are in correct subnets
- [ ] Route tables are associated with correct subnets

---

**Your VPC is now configured for production use!** 🎉

For integration with your existing MoneyOne setup, refer to:
- AWS_DEPLOYMENT_GUIDE.md
- COMPLETE_BEGINNER_GUIDE_AWS_SETUP.md
- AWS_LOAD_BALANCING_GUIDE.md
