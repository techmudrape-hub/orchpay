# Moneyone AWS Architecture Diagram

## Current Architecture (Before Migration)

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTP/HTTPS
                         │
                    ┌────▼─────┐
                    │  Your    │
                    │  Domain  │
                    │  DNS     │
                    └────┬─────┘
                         │
                         │
                    ┌────▼──────────────────────────────────┐
                    │      Single EC2 Instance              │
                    │  ┌─────────────────────────────────┐  │
                    │  │   Frontend (React)              │  │
                    │  │   - Admin Dashboard (Port 3001) │  │
                    │  │   - Client Portal (Port 3000)   │  │
                    │  └─────────────────────────────────┘  │
                    │                                        │
                    │  ┌─────────────────────────────────┐  │
                    │  │   Backend (Flask/Python)        │  │
                    │  │   - API Server (Port 5000)      │  │
                    │  └─────────────────────────────────┘  │
                    │                                        │
                    │  ┌─────────────────────────────────┐  │
                    │  │   MySQL Database                │  │
                    │  │   - Local Installation          │  │
                    │  │   - Single Point of Failure     │  │
                    │  └─────────────────────────────────┘  │
                    └────────────────────────────────────────┘

Problems:
❌ Single point of failure
❌ No load balancing
❌ No auto-scaling
❌ Database on same server
❌ Limited capacity
❌ Difficult to scale
```

## New Architecture (After Migration)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Internet                                         │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │
                                     │ HTTPS
                                     │
                                ┌────▼─────┐
                                │  Route53 │
                                │   DNS    │
                                └────┬─────┘
                                     │
                                     │
                    ┌────────────────▼────────────────┐
                    │  Application Load Balancer      │
                    │  (moneyone-alb)                 │
                    │  - Health Checks                │
                    │  - SSL Termination              │
                    │  - Traffic Distribution         │
                    └────────┬────────────────────────┘
                             │
                             │ HTTP (Internal)
                             │
                    ┌────────▼────────────┐
                    │   Target Group      │
                    │ (moneyone-backend)  │
                    │  - Health: /health  │
                    │  - Port: 5000       │
                    └────────┬────────────┘
                             │
                             │ Distributes to
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼─────┐        ┌────▼─────┐        ┌────▼─────┐
   │ EC2      │        │ EC2      │        │ EC2      │
   │ Instance │        │ Instance │  ...   │ Instance │
   │    #1    │        │    #2    │        │   #10    │
   └────┬─────┘        └────┬─────┘        └────┬─────┘
        │                   │                    │
        │                   │                    │
        └───────────────────┼────────────────────┘
                            │
                            │ Database Queries
                            │
                    ┌───────▼────────┐
                    │  RDS MySQL     │
                    │  (Multi-AZ)    │
                    │                │
                    │  ┌──────────┐  │
                    │  │ Primary  │  │
                    │  │ Database │  │
                    │  └────┬─────┘  │
                    │       │        │
                    │       │ Sync   │
                    │       │        │
                    │  ┌────▼─────┐  │
                    │  │ Standby  │  │
                    │  │ Database │  │
                    │  └──────────┘  │
                    │                │
                    │  ┌──────────┐  │
                    │  │   Read   │  │
                    │  │ Replica  │  │
                    │  └──────────┘  │
                    └────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Auto Scaling Group                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Scaling Policies:                                     │ │
│  │  - CPU > 70% → Add instance                           │ │
│  │  - CPU < 30% → Remove instance                        │ │
│  │  - Min: 2 instances                                   │ │
│  │  - Max: 10 instances                                  │ │
│  │  - Desired: 3 instances                               │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              CloudWatch Monitoring                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Metrics:                                              │ │
│  │  - Request Count                                       │ │
│  │  - Response Time                                       │ │
│  │  - Error Rate                                          │ │
│  │  - CPU Utilization                                     │ │
│  │  - Database Connections                                │ │
│  │                                                        │ │
│  │  Alarms:                                               │ │
│  │  - High CPU → SNS → Email                             │ │
│  │  - High Errors → SNS → Email                          │ │
│  │  - Unhealthy Targets → SNS → Email                    │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Benefits:
✅ High availability (Multi-AZ)
✅ Auto-scaling (2-10 instances)
✅ Load balancing
✅ Database redundancy
✅ Automatic failover
✅ Health monitoring
✅ Can handle 10x traffic
```

## Traffic Flow

### Normal Request Flow

```
1. User Request
   │
   ├─→ Browser: https://moneyone.com/api/payin
   │
   └─→ Route53 DNS
       │
       └─→ Resolves to: moneyone-alb-xxxxx.elb.amazonaws.com

2. Load Balancer
   │
   ├─→ Receives request on port 443 (HTTPS)
   │
   ├─→ Terminates SSL
   │
   ├─→ Checks target health
   │
   └─→ Forwards to healthy instance on port 5000 (HTTP)

3. EC2 Instance
   │
   ├─→ Backend receives request
   │
   ├─→ Validates JWT token
   │
   ├─→ Queries RDS database
   │
   └─→ Returns response

4. Response Path
   │
   ├─→ Backend → Load Balancer
   │
   ├─→ Load Balancer → User
   │
   └─→ User sees result
```

### Health Check Flow

```
Every 30 seconds:

Load Balancer
   │
   ├─→ Sends: GET /health to Instance #1
   │   └─→ Response: 200 OK → Mark as Healthy
   │
   ├─→ Sends: GET /health to Instance #2
   │   └─→ Response: 200 OK → Mark as Healthy
   │
   └─→ Sends: GET /health to Instance #3
       └─→ Response: 503 Error → Mark as Unhealthy
           │
           └─→ Stop sending traffic to Instance #3
               │
               └─→ Auto Scaling replaces unhealthy instance
```

### Auto Scaling Flow

```
Scenario: Traffic Spike

1. Normal Load (2 instances)
   │
   ├─→ CPU: 40%
   └─→ Requests: 1000/min

2. Traffic Increases
   │
   ├─→ CPU: 75% (exceeds 70% threshold)
   │
   └─→ CloudWatch triggers alarm

3. Auto Scaling Action
   │
   ├─→ Launch new instance from template
   │
   ├─→ Wait for health check (5 minutes)
   │
   └─→ Add to target group

4. New Capacity (3 instances)
   │
   ├─→ CPU: 50% (distributed load)
   └─→ Requests: 1000/min (same traffic, more capacity)

5. Traffic Decreases
   │
   ├─→ CPU: 25% (below 30% threshold)
   │
   └─→ Auto Scaling removes 1 instance

6. Back to Normal (2 instances)
```

## Database Architecture

### RDS Multi-AZ Setup

```
┌─────────────────────────────────────────────────────────┐
│                    Availability Zone A                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Primary RDS Instance                       │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  MySQL Database                              │ │ │
│  │  │  - Handles all writes                        │ │ │
│  │  │  - Handles reads                             │ │ │
│  │  │  - Synchronous replication to standby        │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
                            │ Synchronous
                            │ Replication
                            │
┌─────────────────────────────────────────────────────────┐
│                    Availability Zone B                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Standby RDS Instance                       │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  MySQL Database (Replica)                    │ │ │
│  │  │  - Receives all changes                      │ │ │
│  │  │  - Automatic failover if primary fails       │ │ │
│  │  │  - Becomes primary in 1-2 minutes            │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
                            │ Asynchronous
                            │ Replication
                            │
┌─────────────────────────────────────────────────────────┐
│                    Availability Zone C                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Read Replica (Optional)                    │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  MySQL Database (Read-Only)                  │ │ │
│  │  │  - Handles report queries                    │ │ │
│  │  │  - Reduces load on primary                   │ │ │
│  │  │  - Slight replication lag (seconds)          │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Internet (0.0.0.0/0)                  │
└────────────────────────┬────────────────────────────────┘
                         │
                         │ HTTPS (443)
                         │ HTTP (80)
                         │
                    ┌────▼─────────────────────────────┐
                    │  ALB Security Group              │
                    │  (moneyone-alb-sg)               │
                    │  Inbound:                        │
                    │  - Port 443 from 0.0.0.0/0       │
                    │  - Port 80 from 0.0.0.0/0        │
                    └────┬─────────────────────────────┘
                         │
                         │ HTTP (5000)
                         │
                    ┌────▼─────────────────────────────┐
                    │  EC2 Security Group              │
                    │  (moneyone-backend-sg)           │
                    │  Inbound:                        │
                    │  - Port 5000 from ALB SG only    │
                    │  - Port 22 from Your IP          │
                    └────┬─────────────────────────────┘
                         │
                         │ MySQL (3306)
                         │
                    ┌────▼─────────────────────────────┐
                    │  RDS Security Group              │
                    │  (moneyone-rds-sg)               │
                    │  Inbound:                        │
                    │  - Port 3306 from EC2 SG only    │
                    │  - No public access              │
                    └──────────────────────────────────┘
```

## Capacity Planning

### Current Capacity (Single EC2)

```
┌─────────────────────────────────────────┐
│  Single t3.medium Instance              │
│  ┌───────────────────────────────────┐  │
│  │ Max Capacity:                     │  │
│  │ - 500 concurrent users            │  │
│  │ - 1,000 requests/minute           │  │
│  │ - 50 transactions/second          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘

Problem: Traffic spike → Server overload → Downtime
```

### New Capacity (Auto Scaling)

```
┌─────────────────────────────────────────────────────────┐
│  Minimum (2 instances)                                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Baseline Capacity:                                │  │
│  │ - 1,000 concurrent users                          │  │
│  │ - 2,000 requests/minute                           │  │
│  │ - 100 transactions/second                         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Auto-scales up
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Maximum (10 instances)                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Peak Capacity:                                    │  │
│  │ - 5,000 concurrent users                          │  │
│  │ - 10,000 requests/minute                          │  │
│  │ - 500 transactions/second                         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘

Benefit: Automatic scaling → No downtime → Happy users
```

## Cost Comparison

### Current Setup (Single EC2)

```
┌─────────────────────────────────────┐
│  Monthly Cost: ~$50                 │
│  ┌───────────────────────────────┐  │
│  │ EC2 t3.medium: $30            │  │
│  │ EBS Storage: $10              │  │
│  │ Data Transfer: $10            │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘

Risk: Single point of failure, limited capacity
```

### New Setup (Production)

```
┌─────────────────────────────────────┐
│  Monthly Cost: ~$215                │
│  ┌───────────────────────────────┐  │
│  │ RDS db.t3.medium: $120        │  │
│  │ EC2 (2-3 instances): $60-90   │  │
│  │ Load Balancer: $25            │  │
│  │ Data Transfer: $10-20         │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘

Benefit: High availability, auto-scaling, 10x capacity
ROI: Prevents downtime, handles growth, professional setup
```

## Migration Timeline

```
Week 1: Preparation & Planning
├─ Day 1-2: Backup current system
├─ Day 3-4: Create RDS database
└─ Day 5-7: Test RDS connection

Week 2: Database Migration
├─ Day 1-2: Migrate data to RDS
├─ Day 3-4: Update backend configuration
└─ Day 5-7: Test application with RDS

Week 3: Load Balancer Setup
├─ Day 1-2: Create ALB and target groups
├─ Day 3-4: Create AMI and launch template
└─ Day 5-7: Set up Auto Scaling Group

Week 4: Testing & Optimization
├─ Day 1-2: Load testing
├─ Day 3-4: Security hardening
└─ Day 5-7: Monitoring setup

Week 5: Go Live
├─ Day 1-2: Update DNS
├─ Day 3-4: Monitor production
└─ Day 5-7: Cleanup old setup
```

---

**This architecture provides:**
- ✅ 99.9% uptime
- ✅ 10x capacity
- ✅ Automatic scaling
- ✅ Database redundancy
- ✅ Load balancing
- ✅ Health monitoring
- ✅ Disaster recovery
