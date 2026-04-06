#!/bin/bash

# Check ALB Configuration for X-Forwarded-For Headers

echo "🔍 Checking AWS ALB Configuration"
echo "===================================="
echo ""

echo "📋 Step 1: List your Load Balancers"
echo "-----------------------------------"
aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn,DNSName,Scheme]' \
    --output table

echo ""
echo ""

echo "📋 Step 2: Get Target Groups"
echo "----------------------------"
aws elbv2 describe-target-groups \
    --query 'TargetGroups[*].[TargetGroupName,TargetGroupArn,Protocol,Port]' \
    --output table

echo ""
echo ""

echo "⚙️  Step 3: Check Target Group Attributes"
echo "----------------------------------------"
echo "Enter your Target Group ARN (from above):"
read TG_ARN

if [ -n "$TG_ARN" ]; then
    aws elbv2 describe-target-group-attributes \
        --target-group-arn "$TG_ARN" \
        --query 'Attributes[*].[Key,Value]' \
        --output table
    
    echo ""
    echo "✅ Key Attributes to Check:"
    echo "  - preserve_client_ip.enabled should be 'true'"
    echo "  - proxy_protocol_v2.enabled (for NLB)"
fi

echo ""
echo ""

echo "📊 Step 4: Check Load Balancer Attributes"
echo "-----------------------------------------"
echo "Enter your Load Balancer ARN (from step 1):"
read LB_ARN

if [ -n "$LB_ARN" ]; then
    aws elbv2 describe-load-balancer-attributes \
        --load-balancer-arn "$LB_ARN" \
        --query 'Attributes[*].[Key,Value]' \
        --output table
fi

echo ""
echo ""

echo "💡 IMPORTANT:"
echo "============="
echo ""
echo "AWS ALB automatically adds these headers:"
echo "  • X-Forwarded-For: Client IP"
echo "  • X-Forwarded-Proto: http or https"
echo "  • X-Forwarded-Port: Port number"
echo ""
echo "If you're seeing 172.31.x.x, it means:"
echo "  1. ALB is working correctly"
echo "  2. But your app isn't reading X-Forwarded-For header"
echo "  3. OR the header is being stripped somewhere"
echo ""
echo "Next Steps:"
echo "  1. Deploy the updated app.py with debug logging"
echo "  2. Make a test request"
echo "  3. Check logs: sudo journalctl -u gunicorn -f | grep DEBUG"
