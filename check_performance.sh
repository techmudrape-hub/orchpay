#!/bin/bash

echo "🔍 MoneyOne Performance Check"
echo "=============================="
echo ""

# 1. Check Gunicorn workers
echo "1️⃣  Gunicorn Workers:"
WORKER_COUNT=$(ps aux | grep gunicorn | grep -v grep | wc -l)
echo "   Total processes: $WORKER_COUNT"
if [ $WORKER_COUNT -ge 5 ]; then
    echo "   ✅ Multiple workers running"
else
    echo "   ❌ Only $WORKER_COUNT process(es) - should be 5 (1 master + 4 workers)"
fi
echo ""

# 2. Check service status
echo "2️⃣  Service Status:"
if systemctl is-active --quiet moneyone-api; then
    echo "   ✅ Service is running"
else
    echo "   ❌ Service is not running"
fi
echo ""

# 3. Check CPU usage
echo "3️⃣  CPU Usage:"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "   CPU: ${CPU_USAGE}%"
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "   ⚠️  High CPU usage"
else
    echo "   ✅ CPU usage normal"
fi
echo ""

# 4. Check memory usage
echo "4️⃣  Memory Usage:"
MEM_USAGE=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
echo "   Memory: ${MEM_USAGE}%"
if (( $(echo "$MEM_USAGE > 85" | bc -l) )); then
    echo "   ⚠️  High memory usage"
else
    echo "   ✅ Memory usage normal"
fi
echo ""

# 5. Check disk space
echo "5️⃣  Disk Space:"
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
echo "   Disk: ${DISK_USAGE}%"
if [ $DISK_USAGE -gt 85 ]; then
    echo "   ⚠️  Low disk space"
else
    echo "   ✅ Disk space OK"
fi
echo ""

# 6. Check if backend is responding
echo "6️⃣  Backend Response:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/admin/captcha | grep -q "200"; then
    echo "   ✅ Backend responding"
else
    echo "   ❌ Backend not responding"
fi
echo ""

# 7. Check recent errors
echo "7️⃣  Recent Errors (last 10):"
if [ -f /var/log/moneyone/error.log ]; then
    ERROR_COUNT=$(tail -100 /var/log/moneyone/error.log | grep -i error | wc -l)
    echo "   Errors in last 100 lines: $ERROR_COUNT"
    if [ $ERROR_COUNT -gt 10 ]; then
        echo "   ⚠️  Many errors detected"
        echo "   Last error:"
        tail -100 /var/log/moneyone/error.log | grep -i error | tail -1
    else
        echo "   ✅ Error count normal"
    fi
else
    echo "   ⚠️  Log file not found"
fi
echo ""

# 8. Check database connectivity
echo "8️⃣  Database Connection:"
cd /var/www/moneyone/moneyone/backend
if source venv/bin/activate && python -c "from database_pooled import get_db_connection; conn = get_db_connection(); print('✅ Database connected' if conn else '❌ Database connection failed')"; then
    :
else
    echo "   ❌ Failed to test database connection"
fi
echo ""

# Summary
echo "=============================="
echo "📊 Summary:"
if [ $WORKER_COUNT -ge 5 ] && systemctl is-active --quiet moneyone-api; then
    echo "✅ System appears healthy"
    echo ""
    echo "💡 If still experiencing slowness:"
    echo "   1. Check AWS Load Balancer target health"
    echo "   2. Consider scaling up instance size"
    echo "   3. Add more instances behind load balancer"
else
    echo "⚠️  Issues detected - review above"
    echo ""
    echo "🔧 Quick fixes:"
    echo "   - Increase workers: bash fix_workers_now.sh"
    echo "   - Restart service: sudo systemctl restart moneyone-api"
    echo "   - Check logs: sudo journalctl -u moneyone-api -n 50"
fi
