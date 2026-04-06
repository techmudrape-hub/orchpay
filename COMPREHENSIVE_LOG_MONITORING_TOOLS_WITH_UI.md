# Comprehensive Log Monitoring Tools with UI (Non-Docker Backend)

**Multiple UI-based log monitoring solutions for your backend running directly on server**

---

## Option 1: Grafana + Loki + Promtail (RECOMMENDED)

**Best overall solution with beautiful UI, real-time monitoring, and powerful features**

### Step 1: Install Loki (Log Aggregation)
```bash
# Download Loki
cd /tmp
wget https://github.com/grafana/loki/releases/download/v2.9.4/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chmod +x /usr/local/bin/loki

# Create Loki config
sudo mkdir -p /etc/loki
sudo tee /etc/loki/loki.yml << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093
EOF

# Create systemd service
sudo tee /etc/systemd/system/loki.service << 'EOF'
[Unit]
Description=Loki service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/loki -config.file /etc/loki/loki.yml
Restart=on-failure
RestartSec=20
StandardOutput=journal
StandardError=journal
SyslogIdentifier=loki

[Install]
WantedBy=multi-user.target
EOF

# Start Loki
sudo systemctl daemon-reload
sudo systemctl enable loki
sudo systemctl start loki
```

### Step 2: Install Promtail (Log Shipper)
```bash
# Download Promtail
cd /tmp
wget https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

# Create Promtail config
sudo mkdir -p /etc/promtail
sudo tee /etc/promtail/promtail.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: moneyone-backend
    static_configs:
      - targets:
          - localhost
        labels:
          job: moneyone-backend
          __path__: /var/www/moneyone/moneyone/backend/dozzle_logs/*.log
    pipeline_stages:
      - match:
          selector: '{job="moneyone-backend"}'
          stages:
            - regex:
                expression: '^\[(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] (?P<level>\w+): (?P<message>.*)'
            - labels:
                level:
            - timestamp:
                source: timestamp
                format: '2006-01-02 15:04:05'
EOF

# Create systemd service
sudo tee /etc/systemd/system/promtail.service << 'EOF'
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/promtail.yml
Restart=on-failure
RestartSec=20
StandardOutput=journal
StandardError=journal
SyslogIdentifier=promtail

[Install]
WantedBy=multi-user.target
EOF

# Start Promtail
sudo systemctl daemon-reload
sudo systemctl enable promtail
sudo systemctl start promtail
```

### Step 3: Install Grafana (UI Dashboard)
```bash
# Add Grafana repository
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Install Grafana
sudo apt-get update
sudo apt-get install grafana

# Start Grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

### Step 4: Configure Grafana
```bash
# Open AWS Security Group for port 3000
# Access: http://YOUR_IP:3000
# Default login: admin/admin

# Add Loki as data source:
# URL: http://localhost:3100
# Save & Test
```

---

## Option 2: GoAccess (Real-time Web Log Analyzer)

**Lightweight, fast, and beautiful real-time web interface**

### Installation & Setup
```bash
# Install GoAccess
sudo apt update
sudo apt install goaccess -y

# Create custom log format for your backend
sudo tee /etc/goaccess/goaccess.conf << 'EOF'
time-format %H:%M:%S
date-format %Y-%m-%d
log-format [%d %t] %^: %h %^ %m %U %^ %s

# Enable real-time HTML output
real-time-html true
ws-url wss://YOUR_IP:7890
port 7890
addr 0.0.0.0
EOF

# Start GoAccess with real-time monitoring
goaccess backend/dozzle_logs/app.log -o /var/www/html/moneyone-logs.html --log-format='[%d %t] %^: %^ %m %U %^ %^ %s' --date-format='%Y-%m-%d' --time-format='%H:%M:%S' --real-time-html --ws-url=ws://YOUR_IP:7890 --port=7890 --addr=0.0.0.0 &

# Access: http://YOUR_IP/moneyone-logs.html
```

---

## Option 3: Elastic Stack (ELK) - Lightweight Version

**Professional-grade logging with Kibana UI**

### Step 1: Install Elasticsearch
```bash
# Install Java
sudo apt update
sudo apt install openjdk-11-jdk -y

# Add Elastic repository
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

# Install Elasticsearch
sudo apt update
sudo apt install elasticsearch -y

# Configure Elasticsearch
sudo tee -a /etc/elasticsearch/elasticsearch.yml << 'EOF'
network.host: localhost
http.port: 9200
cluster.initial_master_nodes: ["node-1"]
node.name: node-1
EOF

# Start Elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

### Step 2: Install Kibana
```bash
# Install Kibana
sudo apt install kibana -y

# Configure Kibana
sudo tee -a /etc/kibana/kibana.yml << 'EOF'
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOF

# Start Kibana
sudo systemctl enable kibana
sudo systemctl start kibana
```

### Step 3: Install Filebeat
```bash
# Install Filebeat
sudo apt install filebeat -y

# Configure Filebeat
sudo tee /etc/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/www/moneyone/moneyone/backend/dozzle_logs/*.log
  fields:
    service: moneyone-backend
  fields_under_root: true

output.elasticsearch:
  hosts: ["localhost:9200"]

setup.kibana:
  host: "localhost:5601"

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
EOF

# Enable and start Filebeat
sudo filebeat modules enable system
sudo filebeat setup -e
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

---

## Option 4: Fluentd + Grafana (Lightweight Alternative)

**Simple and effective log collection with Grafana visualization**

### Step 1: Install Fluentd
```bash
# Install Ruby and Fluentd
curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent4.sh | sh

# Configure Fluentd
sudo tee /etc/td-agent/td-agent.conf << 'EOF'
<source>
  @type tail
  path /var/www/moneyone/moneyone/backend/dozzle_logs/*.log
  pos_file /var/log/td-agent/moneyone.log.pos
  tag moneyone.backend
  format /^\[(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] (?<level>\w+): (?<message>.*)/
  time_format %Y-%m-%d %H:%M:%S
</source>

<match moneyone.**>
  @type file
  path /var/log/td-agent/moneyone
  append true
  time_slice_format %Y%m%d
  time_slice_wait 10m
  time_format %Y%m%dT%H%M%S%z
  compress gzip
</match>
EOF

# Start Fluentd
sudo systemctl enable td-agent
sudo systemctl start td-agent
```

---

## Option 5: Simple Web-based Log Viewer (Custom Solution)

**Quick and easy custom web interface**

### Create Simple Log Viewer
```bash
# Install Python dependencies
pip3 install flask flask-socketio

# Create log viewer application
cat > log_viewer.py << 'EOF'
#!/usr/bin/env python3
from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit
import os
import time
import threading
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key'
socketio = SocketIO(app, cors_allowed_origins="*")

LOG_FILE = '/var/www/moneyone/moneyone/backend/dozzle_logs/app.log'

@app.route('/')
def index():
    return render_template('log_viewer.html')

@app.route('/api/logs')
def get_logs():
    lines = request.args.get('lines', 100, type=int)
    search = request.args.get('search', '', type=str)
    
    try:
        with open(LOG_FILE, 'r') as f:
            all_lines = f.readlines()
            
        # Filter lines if search term provided
        if search:
            all_lines = [line for line in all_lines if search.lower() in line.lower()]
            
        # Get last N lines
        recent_lines = all_lines[-lines:] if len(all_lines) > lines else all_lines
        
        return {'logs': recent_lines, 'total': len(all_lines)}
    except Exception as e:
        return {'error': str(e)}, 500

def tail_log_file():
    """Monitor log file for changes and emit to connected clients"""
    last_size = 0
    while True:
        try:
            if os.path.exists(LOG_FILE):
                current_size = os.path.getsize(LOG_FILE)
                if current_size > last_size:
                    with open(LOG_FILE, 'r') as f:
                        f.seek(last_size)
                        new_lines = f.readlines()
                        for line in new_lines:
                            socketio.emit('new_log', {'line': line.strip()})
                    last_size = current_size
            time.sleep(1)
        except Exception as e:
            print(f"Error monitoring log: {e}")
            time.sleep(5)

@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('status', {'msg': 'Connected to MoneyOne Log Viewer'})

if __name__ == '__main__':
    # Start log monitoring in background
    log_thread = threading.Thread(target=tail_log_file, daemon=True)
    log_thread.start()
    
    socketio.run(app, host='0.0.0.0', port=8888, debug=False)
EOF

# Create HTML template directory
mkdir -p templates

# Create HTML template
cat > templates/log_viewer.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>MoneyOne Backend Logs</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.0.1/socket.io.js"></script>
    <style>
        body { font-family: 'Courier New', monospace; margin: 0; padding: 20px; background: #1a1a1a; color: #00ff00; }
        .header { background: #333; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .controls { margin-bottom: 20px; }
        .controls input, .controls button { padding: 8px; margin: 5px; border: 1px solid #555; background: #333; color: #fff; }
        .log-container { background: #000; border: 1px solid #333; height: 600px; overflow-y: auto; padding: 10px; font-size: 12px; }
        .log-line { margin: 2px 0; }
        .log-line.error { color: #ff4444; }
        .log-line.info { color: #44ff44; }
        .log-line.warning { color: #ffff44; }
        .status { position: fixed; top: 10px; right: 10px; background: #333; padding: 10px; border-radius: 5px; }
        .connected { color: #44ff44; }
        .disconnected { color: #ff4444; }
    </style>
</head>
<body>
    <div class="header">
        <h1>MoneyOne Backend Real-time Logs</h1>
        <div class="status" id="status">Connecting...</div>
    </div>
    
    <div class="controls">
        <input type="text" id="searchInput" placeholder="Search logs..." />
        <button onclick="searchLogs()">Search</button>
        <button onclick="clearLogs()">Clear</button>
        <button onclick="toggleAutoScroll()">Toggle Auto-scroll</button>
        <select id="linesSelect">
            <option value="50">Last 50 lines</option>
            <option value="100" selected>Last 100 lines</option>
            <option value="500">Last 500 lines</option>
            <option value="1000">Last 1000 lines</option>
        </select>
        <button onclick="loadLogs()">Refresh</button>
    </div>
    
    <div class="log-container" id="logContainer"></div>

    <script>
        const socket = io();
        let autoScroll = true;
        const logContainer = document.getElementById('logContainer');
        const statusDiv = document.getElementById('status');

        socket.on('connect', function() {
            statusDiv.textContent = 'Connected';
            statusDiv.className = 'status connected';
            loadLogs();
        });

        socket.on('disconnect', function() {
            statusDiv.textContent = 'Disconnected';
            statusDiv.className = 'status disconnected';
        });

        socket.on('new_log', function(data) {
            addLogLine(data.line);
        });

        function addLogLine(line) {
            const logLine = document.createElement('div');
            logLine.className = 'log-line';
            
            if (line.includes('ERROR')) {
                logLine.classList.add('error');
            } else if (line.includes('INFO')) {
                logLine.classList.add('info');
            } else if (line.includes('WARNING')) {
                logLine.classList.add('warning');
            }
            
            logLine.textContent = line;
            logContainer.appendChild(logLine);
            
            if (autoScroll) {
                logContainer.scrollTop = logContainer.scrollHeight;
            }
            
            // Keep only last 1000 lines
            while (logContainer.children.length > 1000) {
                logContainer.removeChild(logContainer.firstChild);
            }
        }

        function loadLogs() {
            const lines = document.getElementById('linesSelect').value;
            const search = document.getElementById('searchInput').value;
            
            fetch(`/api/logs?lines=${lines}&search=${encodeURIComponent(search)}`)
                .then(response => response.json())
                .then(data => {
                    logContainer.innerHTML = '';
                    if (data.logs) {
                        data.logs.forEach(line => addLogLine(line.trim()));
                    }
                });
        }

        function searchLogs() {
            loadLogs();
        }

        function clearLogs() {
            logContainer.innerHTML = '';
        }

        function toggleAutoScroll() {
            autoScroll = !autoScroll;
        }

        // Search on Enter key
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchLogs();
            }
        });
    </script>
</body>
</html>
EOF

# Make executable
chmod +x log_viewer.py

# Create systemd service
sudo tee /etc/systemd/system/moneyone-log-viewer.service << 'EOF'
[Unit]
Description=MoneyOne Log Viewer
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/moneyone/moneyone
ExecStart=/usr/bin/python3 log_viewer.py
Restart=on-failure
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF

# Start the service
sudo systemctl daemon-reload
sudo systemctl enable moneyone-log-viewer
sudo systemctl start moneyone-log-viewer
```

---

## Quick Setup Commands for Each Option

### Option 1 (Grafana + Loki) - RECOMMENDED
```bash
# Run the Loki, Promtail, and Grafana installation commands above
# Access: http://YOUR_IP:3000
# Login: admin/admin
```

### Option 2 (GoAccess) - FASTEST SETUP
```bash
sudo apt install goaccess -y
goaccess backend/dozzle_logs/app.log -o /var/www/html/logs.html --log-format='[%d %t] %^: %^ %m %U %^ %^ %s' --date-format='%Y-%m-%d' --time-format='%H:%M:%S' --real-time-html --ws-url=ws://YOUR_IP:7890 --port=7890 --addr=0.0.0.0 &
# Access: http://YOUR_IP/logs.html
```

### Option 5 (Custom Web Viewer) - SIMPLEST
```bash
pip3 install flask flask-socketio
# Copy the log_viewer.py and template files above
python3 log_viewer.py
# Access: http://YOUR_IP:8888
```

---

## Comparison Table

| Tool | Setup Time | Features | Resource Usage | Best For |
|------|------------|----------|----------------|----------|
| **Grafana + Loki** | 30 min | ⭐⭐⭐⭐⭐ | Medium | Production, Advanced analytics |
| **GoAccess** | 5 min | ⭐⭐⭐ | Low | Quick setup, Real-time stats |
| **ELK Stack** | 45 min | ⭐⭐⭐⭐⭐ | High | Enterprise, Complex queries |
| **Custom Viewer** | 10 min | ⭐⭐ | Very Low | Simple monitoring |

---

## Recommendation

**For your use case, I recommend Option 1 (Grafana + Loki)** because:
- Beautiful, professional UI
- Real-time log streaming
- Powerful search and filtering
- Alerting capabilities
- Moderate resource usage
- Great for production environments

**For quick testing, use Option 2 (GoAccess)** - it's the fastest to set up and provides immediate results.

All these tools will give you a proper UI interface to monitor your backend logs in real-time, with search, filtering, and visualization capabilities.