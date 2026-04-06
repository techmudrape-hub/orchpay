# AWS Load Balancing Guide for High-Traffic Payment Gateway

## Architecture Overview

```
Internet → Route 53 → Application Load Balancer → Target Groups → EC2 Auto Scaling Group
                                ↓
                          RDS (Multi-AZ) + ElastiCache Redis
```

## Step 1: Application Load Balancer (ALB) Setup

### Create ALB
```bash
# Via AWS CLI
aws elbv2 create-load-balancer \
  --name moneyone-alb \
  --subnets subnet-xxxxx subnet-yyyyy \
  --security-groups sg-xxxxx \
  --scheme internet-facing \
  --type application \
  --ip-address-type ipv4
```

### Configure Target Groups

**Backend API Target Group:**
```bash
aws elbv2 create-target-group \
  --name moneyone-backend-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id vpc-xxxxx \
  --health-check-enabled \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3
```

**Admin Frontend Target Group:**
```bash
aws elbv2 create-target-group \
  --name moneyone-admin-tg \
  --protocol HTTP \
  --port 3001 \
  --vpc-id vpc-xxxxx \
  --health-check-path /
```

**Client Frontend Target Group:**
```bash
aws elbv2 create-target-group \
  --name moneyone-client-tg \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxxxx \
  --health-check-path /
```

## Step 2: Add Health Check Endpoint to Backend

Create `backend/health_check.py`:
```python
from flask import Blueprint, jsonify
import psycopg2
from config import Config

health_bp = Blueprint('health', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for load balancer"""
    try:
        # Check database connection
        conn = psycopg2.connect(Config.DATABASE_URL)
        conn.close()
        
        return jsonify({
            'status': 'healthy',
            'service': 'moneyone-backend'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 503
```

Update `backend/app.py` to register health check:
```python
from health_check import health_bp
app.register_blueprint(health_bp)
```

## Step 3: Auto Scaling Group Configuration

### Launch Template
```bash
aws ec2 create-launch-template \
  --launch-template-name moneyone-backend-template \
  --version-description "v1" \
  --launch-template-data '{
    "ImageId": "ami-xxxxx",
    "InstanceType": "t3.medium",
    "KeyName": "your-key-pair",
    "SecurityGroupIds": ["sg-xxxxx"],
    "UserData": "BASE64_ENCODED_STARTUP_SCRIPT",
    "IamInstanceProfile": {
      "Name": "EC2-CloudWatch-Role"
    },
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [
        {"Key": "Name", "Value": "moneyone-backend"},
        {"Key": "Environment", "Value": "production"}
      ]
    }]
  }'
```

### Auto Scaling Group
```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name moneyone-backend-asg \
  --launch-template LaunchTemplateName=moneyone-backend-template \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 3 \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/moneyone-backend-tg/xxxxx \
  --health-check-type ELB \
  --health-check-grace-period 300 \
  --vpc-zone-identifier "subnet-xxxxx,subnet-yyyyy"
```

## Step 4: Auto Scaling Policies

### CPU-Based Scaling
```bash
# Scale up when CPU > 70%
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name moneyone-backend-asg \
  --policy-name scale-up-cpu \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 70.0
  }'
```

### Request Count Scaling
```bash
# Scale based on requests per target
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name moneyone-backend-asg \
  --policy-name scale-up-requests \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ALBRequestCountPerTarget",
      "ResourceLabel": "app/moneyone-alb/xxxxx/targetgroup/moneyone-backend-tg/xxxxx"
    },
    "TargetValue": 1000.0
  }'
```

## Step 5: User Data Script for Auto Scaling

Create `backend/ec2_userdata.sh`:
```bash
#!/bin/bash
set -e

# Update system
yum update -y

# Install dependencies
yum install -y python3 python3-pip git nginx

# Clone application
cd /opt
git clone https://github.com/your-repo/moneyone.git
cd moneyone/backend

# Install Python dependencies
pip3 install -r requirements.txt

# Set environment variables from Parameter Store
export DATABASE_URL=$(aws ssm get-parameter --name /moneyone/db_url --with-decryption --query 'Parameter.Value' --output text)
export JWT_SECRET=$(aws ssm get-parameter --name /moneyone/jwt_secret --with-decryption --query 'Parameter.Value' --output text)

# Create systemd service
cat > /etc/systemd/system/moneyone-backend.service <<EOF
[Unit]
Description=Moneyone Backend API
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/moneyone/backend
Environment="DATABASE_URL=$DATABASE_URL"
Environment="JWT_SECRET=$JWT_SECRET"
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable moneyone-backend
systemctl start moneyone-backend

# Configure nginx as reverse proxy
cat > /etc/nginx/conf.d/moneyone.conf <<EOF
server {
    listen 5000;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

systemctl restart nginx
```

## Step 6: Database Optimization for High Load

### RDS Multi-AZ Setup
```bash
aws rds create-db-instance \
  --db-instance-identifier moneyone-db \
  --db-instance-class db.r5.xlarge \
  --engine postgres \
  --master-username admin \
  --master-user-password 'YourPassword' \
  --allocated-storage 100 \
  --storage-type gp3 \
  --multi-az \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "mon:04:00-mon:05:00"
```

### Read Replica for Reports
```bash
aws rds create-db-instance-read-replica \
  --db-instance-identifier moneyone-db-read-replica \
  --source-db-instance-identifier moneyone-db \
  --db-instance-class db.r5.large
```

## Step 7: Redis Cache Layer (ElastiCache)

```bash
aws elasticache create-replication-group \
  --replication-group-id moneyone-redis \
  --replication-group-description "Redis for session and caching" \
  --engine redis \
  --cache-node-type cache.r5.large \
  --num-cache-clusters 2 \
  --automatic-failover-enabled \
  --at-rest-encryption-enabled \
  --transit-encryption-enabled
```

### Add Redis to Backend

Update `backend/requirements.txt`:
```
redis==4.5.1
flask-caching==2.0.2
```

Create `backend/cache_config.py`:
```python
from flask_caching import Cache
from redis import Redis
import os

redis_client = Redis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=6379,
    db=0,
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=5
)

cache = Cache(config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_HOST': os.getenv('REDIS_HOST', 'localhost'),
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 0,
    'CACHE_DEFAULT_TIMEOUT': 300
})
```

## Step 8: Application-Level Optimizations

### Connection Pooling

Update `backend/database.py`:
```python
from psycopg2 import pool
import os

# Create connection pool
db_pool = pool.ThreadedConnectionPool(
    minconn=5,
    maxconn=20,
    host=os.getenv('DB_HOST'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)

def get_db_connection():
    return db_pool.getconn()

def return_db_connection(conn):
    db_pool.putconn(conn)
```

### Rate Limiting

Create `backend/rate_limiter.py`:
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from cache_config import redis_client

limiter = Limiter(
    key_func=get_remote_address,
    storage_uri=f"redis://{os.getenv('REDIS_HOST', 'localhost')}:6379",
    default_limits=["1000 per hour", "100 per minute"]
)
```

Apply to routes in `backend/app.py`:
```python
from rate_limiter import limiter

limiter.init_app(app)

# Apply to specific routes
@app.route('/api/payin', methods=['POST'])
@limiter.limit("10 per minute")
def create_payin():
    # Your code
    pass
```

## Step 9: CloudWatch Monitoring

### Custom Metrics Script

Create `backend/cloudwatch_metrics.py`:
```python
import boto3
from datetime import datetime

cloudwatch = boto3.client('cloudwatch', region_name='ap-south-1')

def send_metric(metric_name, value, unit='Count'):
    cloudwatch.put_metric_data(
        Namespace='Moneyone/Backend',
        MetricData=[{
            'MetricName': metric_name,
            'Value': value,
            'Unit': unit,
            'Timestamp': datetime.utcnow()
        }]
    )

# Usage in your routes
def create_payin():
    try:
        # Your payin logic
        send_metric('PayinSuccess', 1)
    except Exception as e:
        send_metric('PayinFailure', 1)
```

### CloudWatch Alarms
```bash
# High CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name moneyone-high-cpu \
  --alarm-description "Alert when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# High error rate alarm
aws cloudwatch put-metric-alarm \
  --alarm-name moneyone-high-errors \
  --alarm-description "Alert on high error rate" \
  --metric-name PayinFailure \
  --namespace Moneyone/Backend \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

## Step 10: Session Management for Load Balancing

### Sticky Sessions (if needed)
```bash
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/moneyone-backend-tg/xxxxx \
  --attributes Key=stickiness.enabled,Value=true \
               Key=stickiness.type,Value=lb_cookie \
               Key=stickiness.lb_cookie.duration_seconds,Value=86400
```

### JWT-Based Stateless Sessions (Recommended)
Your current JWT implementation is already stateless, which is perfect for load balancing.

## Step 11: CDN for Static Assets (CloudFront)

```bash
aws cloudfront create-distribution \
  --origin-domain-name moneyone-alb-xxxxx.ap-south-1.elb.amazonaws.com \
  --default-root-object index.html
```

## Step 12: Deployment Strategy

### Blue-Green Deployment Script

Create `deploy_with_zero_downtime.sh`:
```bash
#!/bin/bash

# Create new launch template version
aws ec2 create-launch-template-version \
  --launch-template-name moneyone-backend-template \
  --source-version 1 \
  --launch-template-data file://new-config.json

# Update ASG to use new version
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name moneyone-backend-asg \
  --launch-template LaunchTemplateName=moneyone-backend-template,Version='$Latest'

# Gradually replace instances
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name moneyone-backend-asg \
  --preferences '{
    "MinHealthyPercentage": 90,
    "InstanceWarmup": 300
  }'
```

## Recommended Instance Configuration

### For Production Load:

**Backend Tier:**
- Instance Type: `t3.medium` or `t3.large`
- Min Instances: 2
- Max Instances: 10
- Desired: 3

**Database:**
- RDS Instance: `db.r5.xlarge` (Multi-AZ)
- Read Replica: `db.r5.large`

**Cache:**
- ElastiCache: `cache.r5.large` (2 nodes)

## Cost Optimization Tips

1. Use Reserved Instances for baseline capacity (30-50% savings)
2. Use Spot Instances for burst capacity (up to 90% savings)
3. Enable Auto Scaling to scale down during low traffic
4. Use S3 for static assets instead of EC2
5. Enable CloudFront caching to reduce backend load

## Performance Benchmarks

Expected capacity per `t3.medium` instance:
- ~500 concurrent connections
- ~1000 requests/minute
- ~50 transactions/second

With 3 instances + auto-scaling:
- ~1500 concurrent connections
- ~3000 requests/minute
- Can scale to 10 instances for peak loads

## Monitoring Dashboard

Key metrics to monitor:
- ALB Request Count
- Target Response Time
- Unhealthy Host Count
- Database Connections
- Redis Hit Rate
- Error Rate (4xx, 5xx)
- Transaction Success Rate

## Next Steps

1. Set up ALB and target groups
2. Create launch template with user data script
3. Configure Auto Scaling Group
4. Set up RDS Multi-AZ
5. Deploy ElastiCache Redis
6. Add health check endpoint
7. Configure CloudWatch alarms
8. Test auto-scaling behavior
9. Perform load testing
10. Set up monitoring dashboard
