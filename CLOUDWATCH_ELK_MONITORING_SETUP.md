# Complete Monitoring Setup Guide: CloudWatch + ELK Stack

## Overview
This guide will help you set up a complete monitoring system for your Flask backend running on AWS EC2 with Load Balancer.

**What you'll get:**
- CloudWatch for basic AWS metrics and alarms
- ELK Stack for detailed API call logging and filtering
- Ability to search logs by time, endpoint, merchant, status, etc.
- Server health monitoring
- All FREE (within AWS free tier limits)

---

## Part 1: CloudWatch Setup (30 minutes)

### Step 1.1: Enable CloudWatch Agent on EC2

SSH into your EC2 instance:

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

Install CloudWatch Agent:

```bash
# Download CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

# Install it
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Verify installation
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a query
```

### Step 1.2: Create IAM Role for CloudWatch

Go to AWS Console → IAM → Roles → Create Role:

1. Select "AWS service" → "EC2"
2. Attach policies:
   - `CloudWatchAgentServerPolicy`
   - `CloudWatchLogsFullAccess`
3. Name it: `EC2-CloudWatch-Role`
4. Click "Create role"

Attach role to your EC2 instance:
- EC2 Console → Select your instance → Actions → Security → Modify IAM role
- Select `EC2-CloudWatch-Role` → Update IAM role

### Step 1.3: Configure CloudWatch Agent

Create configuration file:

```bash
sudo nano /opt/aws/amazon-cloudwatch-agent/etc/config.json
```

Paste this configuration:

```json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/flask/app.log",
            "log_group_name": "/aws/ec2/flask-backend",
            "log_stream_name": "{instance_id}/application",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/flask/error.log",
            "log_group_name": "/aws/ec2/flask-backend",
            "log_stream_name": "{instance_id}/errors",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "FlaskBackend",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_iowait", "rename": "CPU_IOWAIT", "unit": "Percent"}
        ],
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
        ],
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
        ]
      }
    }
  }
}
```

Start CloudWatch Agent:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
```

Verify it's running:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a query \
  -m ec2
```

### Step 1.4: Configure Flask Logging

Create logging configuration in your backend:

```bash
cd /home/ubuntu/backend
nano logging_config.py
```

Add this content:

```python
import logging
import os
from logging.handlers import RotatingFileHandler
import json
from datetime import datetime

# Create logs directory
os.makedirs('/var/log/flask', exist_ok=True)

class JSONFormatter(logging.Formatter):
    """Format logs as JSON for easy parsing"""
    def format(self, record):
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        
        # Add extra fields if available
        if hasattr(record, 'merchant_id'):
            log_data['merchant_id'] = record.merchant_id
        if hasattr(record, 'endpoint'):
            log_data['endpoint'] = record.endpoint
        if hasattr(record, 'status_code'):
            log_data['status_code'] = record.status_code
        if hasattr(record, 'duration'):
            log_data['duration_ms'] = record.duration
            
        return json.dumps(log_data)

def setup_logging(app):
    """Setup application logging"""
    
    # Application log handler
    app_handler = RotatingFileHandler(
        '/var/log/flask/app.log',
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    app_handler.setLevel(logging.INFO)
    app_handler.setFormatter(JSONFormatter())
    
    # Error log handler
    error_handler = RotatingFileHandler(
        '/var/log/flask/error.log',
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(JSONFormatter())
    
    # Add handlers to app logger
    app.logger.addHandler(app_handler)
    app.logger.addHandler(error_handler)
    app.logger.setLevel(logging.INFO)
    
    return app.logger
```

### Step 1.5: Add Request Logging Middleware

Add to your `backend/app.py`:

```python
from logging_config import setup_logging
from flask import request, g
import time

# Setup logging
logger = setup_logging(app)

@app.before_request
def before_request():
    """Log request start time"""
    g.start_time = time.time()

@app.after_request
def after_request(response):
    """Log all API requests"""
    if request.path.startswith('/api/'):
        duration = (time.time() - g.start_time) * 1000  # Convert to ms
        
        # Extract merchant_id if available
        merchant_id = None
        if hasattr(g, 'merchant_id'):
            merchant_id = g.merchant_id
        
        # Log the request
        logger.info(
            f"{request.method} {request.path} - {response.status_code}",
            extra={
                'endpoint': request.path,
                'method': request.method,
                'status_code': response.status_code,
                'duration': duration,
                'merchant_id': merchant_id,
                'ip': request.remote_addr
            }
        )
    
    return response

@app.errorhandler(Exception)
def handle_exception(e):
    """Log all exceptions"""
    logger.error(
        f"Unhandled exception: {str(e)}",
        exc_info=True,
        extra={
            'endpoint': request.path,
            'method': request.method
        }
    )
    return {"error": "Internal server error"}, 500
```

Restart your Flask application:

```bash
sudo systemctl restart flask-backend
```

### Step 1.6: Create CloudWatch Alarms

Go to AWS Console → CloudWatch → Alarms → Create Alarm:

**Alarm 1: High CPU Usage**
- Metric: EC2 → Per-Instance Metrics → CPUUtilization
- Condition: Greater than 80%
- Period: 5 minutes
- Action: Send email notification

**Alarm 2: High Memory Usage**
- Metric: FlaskBackend → MEM_USED
- Condition: Greater than 85%
- Period: 5 minutes
- Action: Send email notification

**Alarm 3: High Error Rate**
- Metric: Logs → Log group `/aws/ec2/flask-backend`
- Filter pattern: `{ $.level = "ERROR" }`
- Condition: Greater than 10 errors in 5 minutes
- Action: Send email notification

### Step 1.7: View Logs in CloudWatch

1. Go to CloudWatch → Log groups
2. Find `/aws/ec2/flask-backend`
3. Click on log streams to view logs
4. Use "Filter events" to search:
   - `{ $.status_code = 500 }` - Find all 500 errors
   - `{ $.merchant_id = "9000000001" }` - Find logs for specific merchant
   - `{ $.endpoint = "/api/payin/create" }` - Find specific endpoint logs

---

## Part 2: ELK Stack Setup (1-2 hours)

### Step 2.1: Install Prerequisites

SSH into your EC2 instance (or use a separate instance for ELK):

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java (required for Elasticsearch)
sudo apt install openjdk-11-jdk -y

# Verify Java installation
java -version
```

### Step 2.2: Install Elasticsearch

```bash
# Import Elasticsearch GPG key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Add Elasticsearch repository
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Install Elasticsearch
sudo apt update
sudo apt install elasticsearch -y
```

Configure Elasticsearch:

```bash
sudo nano /etc/elasticsearch/elasticsearch.yml
```

Update these settings:

```yaml
# Network settings
network.host: localhost
http.port: 9200

# Security settings (disable for local setup)
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false

# Memory settings
bootstrap.memory_lock: true
```

Set memory limits:

```bash
sudo nano /etc/elasticsearch/jvm.options.d/heap.options
```

Add (adjust based on your EC2 instance size):

```
-Xms2g
-Xmx2g
```

Start Elasticsearch:

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Verify it's running
curl -X GET "localhost:9200/"
```

### Step 2.3: Install Logstash

```bash
# Install Logstash
sudo apt install logstash -y
```

Create Logstash configuration:

```bash
sudo nano /etc/logstash/conf.d/flask-logs.conf
```

Add this configuration:

```ruby
input {
  file {
    path => "/var/log/flask/app.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
    codec => "json"
    type => "flask-app"
  }
  
  file {
    path => "/var/log/flask/error.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
    codec => "json"
    type => "flask-error"
  }
}

filter {
  # Parse timestamp
  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
  
  # Add geolocation for IP addresses (optional)
  if [ip] {
    geoip {
      source => "ip"
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "flask-logs-%{+YYYY.MM.dd}"
  }
  
  # Also output to console for debugging
  stdout {
    codec => rubydebug
  }
}
```

Start Logstash:

```bash
sudo systemctl enable logstash
sudo systemctl start logstash

# Check status
sudo systemctl status logstash
```

### Step 2.4: Install Kibana

```bash
# Install Kibana
sudo apt install kibana -y
```

Configure Kibana:

```bash
sudo nano /etc/kibana/kibana.yml
```

Update these settings:

```yaml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
```

Start Kibana:

```bash
sudo systemctl enable kibana
sudo systemctl start kibana

# Check status
sudo systemctl status kibana
```

### Step 2.5: Configure Security Group

In AWS Console → EC2 → Security Groups:

Add inbound rule:
- Type: Custom TCP
- Port: 5601
- Source: Your IP address (for security)
- Description: Kibana access

### Step 2.6: Access Kibana

Open browser and go to:
```
http://your-ec2-public-ip:5601
```

**First Time Setup:**

1. Click "Explore on my own"
2. Go to Management → Stack Management → Index Patterns
3. Click "Create index pattern"
4. Index pattern name: `flask-logs-*`
5. Time field: `@timestamp`
6. Click "Create index pattern"

### Step 2.7: Create Kibana Dashboards

**Dashboard 1: API Request Overview**

1. Go to Analytics → Dashboard → Create dashboard
2. Add visualization → Lens
3. Create these visualizations:

**Total Requests (Metric)**
- Field: Count of records
- Time range: Last 24 hours

**Requests by Status Code (Bar chart)**
- X-axis: status_code
- Y-axis: Count

**Response Time (Line chart)**
- X-axis: @timestamp
- Y-axis: Average of duration_ms

**Top Endpoints (Table)**
- Rows: endpoint
- Metrics: Count, Average duration_ms

**Error Rate (Metric)**
- Filter: level = "ERROR"
- Field: Count

Save dashboard as "API Monitoring"

**Dashboard 2: Merchant Activity**

1. Create new dashboard
2. Add visualizations:

**Requests by Merchant (Pie chart)**
- Slice by: merchant_id
- Size by: Count

**Merchant Request Timeline (Area chart)**
- X-axis: @timestamp
- Y-axis: Count
- Break down by: merchant_id

Save dashboard as "Merchant Activity"

### Step 2.8: Create Saved Searches

Go to Analytics → Discover:

**Search 1: Failed Requests**
```
level: "ERROR" OR status_code: >= 400
```
Save as "Failed Requests"

**Search 2: Slow Requests**
```
duration_ms: > 1000
```
Save as "Slow Requests (>1s)"

**Search 3: Specific Merchant**
```
merchant_id: "9000000001"
```
Save as "Merchant 9000000001 Activity"

---

## Part 3: Testing and Verification

### Step 3.1: Generate Test Traffic

```bash
# Test your API endpoints
curl -X POST http://your-alb-dns/api/payin/create \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "merchant_id": "9000000001"}'
```

### Step 3.2: Verify Logs in CloudWatch

1. Go to CloudWatch → Log groups → `/aws/ec2/flask-backend`
2. You should see JSON formatted logs
3. Try filtering: `{ $.status_code = 200 }`

### Step 3.3: Verify Logs in Kibana

1. Go to Kibana → Analytics → Discover
2. Select index pattern: `flask-logs-*`
3. You should see your API logs
4. Try filtering:
   - `status_code: 200`
   - `endpoint: "/api/payin/create"`
   - `merchant_id: "9000000001"`

---

## Part 4: Common Queries and Filters

### CloudWatch Insights Queries

Go to CloudWatch → Logs → Insights:

**Query 1: Top 10 Slowest Endpoints**
```
fields @timestamp, endpoint, duration_ms
| filter ispresent(duration_ms)
| sort duration_ms desc
| limit 10
```

**Query 2: Error Rate by Endpoint**
```
fields endpoint, status_code
| filter status_code >= 400
| stats count() by endpoint
| sort count desc
```

**Query 3: Requests per Minute**
```
fields @timestamp
| stats count() by bin(5m)
```

### Kibana KQL Queries

In Kibana Discover, use these queries:

**Find all errors in last hour:**
```
level: "ERROR" AND @timestamp >= now-1h
```

**Find slow requests for specific merchant:**
```
merchant_id: "9000000001" AND duration_ms > 500
```

**Find all payin API calls:**
```
endpoint: /api/payin/*
```

**Find requests between specific times:**
```
@timestamp >= "2026-03-19T10:00:00" AND @timestamp <= "2026-03-19T11:00:00"
```

---

## Part 5: Maintenance and Best Practices

### Log Rotation

Logs are automatically rotated (configured in logging_config.py):
- Max size: 10MB per file
- Keep 10 backup files
- Total: ~100MB per log type

### Elasticsearch Index Management

Create index lifecycle policy:

```bash
curl -X PUT "localhost:9200/_ilm/policy/flask-logs-policy" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "5GB",
            "max_age": "7d"
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
'
```

### Monitor Disk Space

```bash
# Check Elasticsearch disk usage
df -h /var/lib/elasticsearch

# Check log disk usage
du -sh /var/log/flask/
```

### Backup Kibana Dashboards

```bash
# Export saved objects
curl -X POST "localhost:5601/api/saved_objects/_export" \
  -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' \
  -d '{"type": ["dashboard", "visualization", "search"]}' \
  > kibana-backup.ndjson
```

---

## Part 6: Cost Optimization

### CloudWatch Free Tier
- 5GB log ingestion per month
- 5GB log storage per month
- 10 custom metrics
- 10 alarms

### ELK Stack (Self-hosted)
- Completely FREE
- Only pay for EC2 instance
- Recommended: t3.medium or larger (2 vCPU, 4GB RAM)

### Tips to Stay in Free Tier
1. Set log retention to 7-14 days
2. Use log sampling for high-traffic endpoints
3. Delete old Elasticsearch indices regularly
4. Use CloudWatch for critical alerts only

---

## Troubleshooting

### CloudWatch Agent Not Sending Logs

```bash
# Check agent status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a query -m ec2

# Check agent logs
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

# Restart agent
sudo systemctl restart amazon-cloudwatch-agent
```

### Elasticsearch Not Starting

```bash
# Check logs
sudo journalctl -u elasticsearch -f

# Check memory
free -h

# Reduce heap size if needed
sudo nano /etc/elasticsearch/jvm.options.d/heap.options
```

### Kibana Not Accessible

```bash
# Check if Kibana is running
sudo systemctl status kibana

# Check Kibana logs
sudo tail -f /var/log/kibana/kibana.log

# Verify security group allows port 5601
```

### Logstash Not Processing Logs

```bash
# Check Logstash status
sudo systemctl status logstash

# Check Logstash logs
sudo tail -f /var/log/logstash/logstash-plain.log

# Test configuration
sudo /usr/share/logstash/bin/logstash --config.test_and_exit -f /etc/logstash/conf.d/flask-logs.conf
```

---

## Quick Reference Commands

```bash
# Check all services
sudo systemctl status elasticsearch
sudo systemctl status logstash
sudo systemctl status kibana
sudo systemctl status amazon-cloudwatch-agent

# Restart all services
sudo systemctl restart elasticsearch
sudo systemctl restart logstash
sudo systemctl restart kibana
sudo systemctl restart amazon-cloudwatch-agent

# View logs
sudo tail -f /var/log/flask/app.log
sudo tail -f /var/log/flask/error.log
sudo journalctl -u elasticsearch -f
sudo journalctl -u logstash -f

# Check Elasticsearch health
curl -X GET "localhost:9200/_cluster/health?pretty"

# List Elasticsearch indices
curl -X GET "localhost:9200/_cat/indices?v"

# Delete old indices (older than 30 days)
curl -X DELETE "localhost:9200/flask-logs-2026.02.*"
```

---

## Next Steps

1. ✅ Complete CloudWatch setup (30 min)
2. ✅ Test CloudWatch logging (10 min)
3. ✅ Install ELK Stack (1 hour)
4. ✅ Create Kibana dashboards (30 min)
5. ✅ Set up alerts and notifications (20 min)
6. 📊 Monitor for 24 hours and adjust
7. 🎯 Create custom dashboards for your use case

---

## Support

If you encounter issues:
1. Check the Troubleshooting section
2. Review service logs
3. Verify security groups and IAM roles
4. Check disk space and memory

Your monitoring system is now ready! 🎉
