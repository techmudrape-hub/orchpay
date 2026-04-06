# Advanced Performance Optimization Guide
## Make Your Dashboard Lightning Fast ⚡

## Current Setup (After Basic Optimization)
- ✅ 4 Gunicorn workers
- ✅ Connection pooling (20 connections)
- ✅ Database indexes
- ✅ RDS db.t4g.medium

## Advanced Optimizations for Near-Zero Lag

### 1. Add Redis Caching (HIGHEST IMPACT) 🚀

Redis will cache frequently accessed data, reducing database queries by 70-90%.

**Install Redis:**
```bash
# On Ubuntu
sudo apt update
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Test Redis
redis-cli ping
# Should return: PONG
```

**Install Python Redis:**
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install redis flask-caching
```

**Create Redis Cache Module:**
```python
# backend/cache_config.py
from flask_caching import Cache
from config import Config

cache = Cache(config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_HOST': 'localhost',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 0,
    'CACHE_DEFAULT_TIMEOUT': 300,  # 5 minutes
    'CACHE_KEY_PREFIX': 'moneyone_'
})
```

**Add to app.py:**
```python
from cache_config import cache

# After app = Flask(__name__)
cache.init_app(app)
```

**Cache Dashboard Data:**
```python
# Example: Cache merchant wallet balance
@app.route('/api/merchant/wallet', methods=['GET'])
@jwt_required()
@cache.cached(timeout=60, key_prefix='wallet_%s' % get_jwt_identity())
def get_wallet_balance():
    # Your existing code
    pass

# Example: Cache transaction stats
@app.route('/api/admin/dashboard/stats', methods=['GET'])
@jwt_required()
@cache.cached(timeout=120, key_prefix='dashboard_stats')
def get_dashboard_stats():
    # Your existing code
    pass
```

**Expected Impact:** 70-80% faster dashboard loads

---

### 2. Use Async Workers (gevent) 🔄

Switch from sync workers to gevent for better concurrency.

**Install gevent:**
```bash
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install gevent
```

**Update systemd service:**
```bash
sudo nano /etc/systemd/system/moneyone-api.service

# Change:
--worker-class sync

# To:
--worker-class gevent --worker-connections 1000
```

**Restart:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart moneyone-api
```

**Expected Impact:** Handle 1000 concurrent connections per worker (4000 total)

---

### 3. Enable Response Compression 📦

Reduce response size by 60-80%.

**Install:**
```bash
pip install flask-compress
```

**Add to app.py:**
```python
from flask_compress import Compress

Compress(app)
```

**Expected Impact:** 60-80% smaller responses, faster page loads

---

### 4. Optimize Database Queries 🗄️

**Add Query Result Caching:**
```python
# Cache expensive queries
@cache.memoize(timeout=300)
def get_merchant_transactions(merchant_id, date_from, date_to):
    conn = get_db_connection()
    # Your query here
    return results
```

**Use SELECT only needed columns:**
```python
# Bad:
cursor.execute("SELECT * FROM payin_transactions WHERE merchant_id = %s", (merchant_id,))

# Good:
cursor.execute("""
    SELECT txn_id, amount, status, created_at 
    FROM payin_transactions 
    WHERE merchant_id = %s
""", (merchant_id,))
```

**Add LIMIT to queries:**
```python
# Always limit results
cursor.execute("""
    SELECT * FROM payin_transactions 
    WHERE merchant_id = %s 
    ORDER BY created_at DESC 
    LIMIT 100
""", (merchant_id,))
```

---

### 5. Frontend Optimizations 🎨

**Add Loading States:**
```javascript
// Show skeleton loaders instead of blank screens
<Skeleton count={5} />
```

**Implement Pagination:**
```javascript
// Load 20 records at a time instead of all
const [page, setPage] = useState(1);
const perPage = 20;
```

**Debounce Search:**
```javascript
// Wait 300ms before searching
const debouncedSearch = debounce(searchFunction, 300);
```

---

### 6. Enable HTTP/2 on ALB 🌐

HTTP/2 multiplexes requests, reducing latency.

**AWS Console:**
1. Go to EC2 > Load Balancers
2. Select your ALB
3. Listeners > HTTPS:443
4. Edit > Advanced settings
5. Enable HTTP/2
6. Save

**Expected Impact:** 20-30% faster page loads

---

### 7. Add CDN for Static Assets 📡

Use CloudFront to cache static files.

**Quick Setup:**
1. AWS Console > CloudFront
2. Create Distribution
3. Origin: Your ALB domain
4. Cache Policy: CachingOptimized
5. Update frontend to use CloudFront URL

**Expected Impact:** 50-70% faster static asset loading

---

### 8. Optimize Gunicorn Settings ⚙️

**Update service file:**
```bash
sudo nano /etc/systemd/system/moneyone-api.service

# Add these flags:
--worker-class gevent \
--worker-connections 1000 \
--workers 4 \
--timeout 120 \
--keepalive 5 \
--max-requests 1000 \
--max-requests-jitter 50 \
--preload
```

**Explanation:**
- `--keepalive 5`: Reuse connections
- `--max-requests 1000`: Restart workers after 1000 requests (prevent memory leaks)
- `--preload`: Load app before forking (faster startup)

---

### 9. Database Query Optimization 📊

**Add Composite Indexes:**
```sql
-- For merchant transaction queries
CREATE INDEX idx_merchant_status_date 
ON payin_transactions(merchant_id, status, created_at);

-- For admin dashboard
CREATE INDEX idx_status_date 
ON payin_transactions(status, created_at);

-- For payout queries
CREATE INDEX idx_merchant_payout_status 
ON payout_transactions(merchant_id, status, created_at);
```

**Enable Query Cache on RDS:**
```sql
-- Connect to RDS
mysql -h your-rds-endpoint -u admin -p

-- Enable query cache
SET GLOBAL query_cache_type = 1;
SET GLOBAL query_cache_size = 67108864;  -- 64MB
```

---

### 10. Monitor and Profile 📈

**Add Performance Monitoring:**
```bash
pip install flask-profiler
```

```python
# In app.py
from flask_profiler import Profiler

app.config["flask_profiler"] = {
    "enabled": True,
    "storage": {
        "engine": "sqlite"
    },
    "basicAuth": {
        "enabled": True,
        "username": "admin",
        "password": "admin"
    }
}

profiler = Profiler()
profiler.init_app(app)
```

**Access:** `http://your-domain/flask-profiler/`

---

## Complete Implementation Script

I'll create a script that implements all these optimizations:

```bash
#!/bin/bash
# advanced_optimization.sh

echo "🚀 Advanced Performance Optimization"
echo "===================================="

# 1. Install Redis
echo "📦 Installing Redis..."
sudo apt update
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server

# 2. Install Python packages
echo "📦 Installing Python packages..."
cd /var/www/moneyone/moneyone/backend
source venv/bin/activate
pip install redis flask-caching flask-compress gevent

# 3. Update Gunicorn to use gevent
echo "⚙️  Updating Gunicorn configuration..."
sudo sed -i 's/--worker-class sync/--worker-class gevent --worker-connections 1000/g' /etc/systemd/system/moneyone-api.service

# 4. Add performance flags
sudo sed -i 's/--timeout 120/--timeout 120 --keepalive 5 --max-requests 1000 --max-requests-jitter 50 --preload/g' /etc/systemd/system/moneyone-api.service

# 5. Restart service
echo "🔄 Restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart moneyone-api

echo "✅ Advanced optimization complete!"
echo ""
echo "📊 Performance Improvements:"
echo "   - Redis caching: 70-80% faster queries"
echo "   - Gevent workers: 4000 concurrent connections"
echo "   - Compression: 60-80% smaller responses"
echo "   - Optimized settings: Better resource usage"
echo ""
echo "🔍 Next steps:"
echo "   1. Add cache decorators to routes (see guide)"
echo "   2. Enable HTTP/2 on ALB"
echo "   3. Add CloudFront CDN"
echo "   4. Monitor with flask-profiler"
```

---

## Expected Performance After All Optimizations

### Before:
- Dashboard load: 5-10 seconds
- Transaction list: 3-5 seconds
- API response: 1-2 seconds
- Concurrent users: ~10-20

### After:
- Dashboard load: 0.5-1 second ⚡
- Transaction list: 0.3-0.5 seconds ⚡
- API response: 0.1-0.3 seconds ⚡
- Concurrent users: ~500-1000 ⚡

---

## Priority Order (Do These First)

1. **Redis Caching** (Highest impact, easiest)
2. **Gevent Workers** (2x-4x more concurrent connections)
3. **Response Compression** (Faster page loads)
4. **Database Query Optimization** (Reduce query time)
5. **HTTP/2 on ALB** (Better multiplexing)
6. **CDN** (Faster static assets)

---

## Monitoring Commands

```bash
# Check Redis
redis-cli info stats

# Check cache hit rate
redis-cli info stats | grep keyspace_hits

# Monitor Gunicorn workers
ps aux | grep gunicorn

# Check response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:5000/api/admin/captcha

# Monitor database connections
mysql -h your-rds-endpoint -u admin -p -e "SHOW PROCESSLIST;"
```

---

## Troubleshooting

### Redis not starting:
```bash
sudo systemctl status redis-server
sudo journalctl -u redis-server -n 50
```

### Gevent import error:
```bash
pip install --upgrade gevent greenlet
```

### High memory usage:
```bash
# Reduce workers or add swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## Cost Considerations

- Redis on same server: $0 (uses ~100MB RAM)
- CloudFront: ~$5-10/month for low traffic
- Larger instance (if needed): ~$30-50/month more

**Total additional cost: $5-15/month for massive performance gains**
