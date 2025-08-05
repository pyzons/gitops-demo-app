#!/bin/bash

# Check Container Insights Status
# This script provides a comprehensive status check of your monitoring setup

set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"

echo "🔍 Container Insights Status Check"
echo "=================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""

# Check monitoring pods
echo "📊 Monitoring Infrastructure:"
echo "-----------------------------"
echo "CloudWatch Agent:"
kubectl get pods -n amazon-cloudwatch -l app.kubernetes.io/name=cloudwatch-agent --no-headers | while read line; do
    echo "  ✅ $line"
done

echo ""
echo "Fluent Bit:"
kubectl get pods -n amazon-cloudwatch -l k8s-app=fluent-bit --no-headers | while read line; do
    echo "  ✅ $line"
done

# Check application pods
echo ""
echo "🛍️ E-Commerce Application Status:"
echo "----------------------------------"
echo "Backend Services (ecommerce-backend):"
kubectl get pods -n ecommerce-backend --no-headers | while read line; do
    echo "  📦 $line"
done

echo ""
echo "Database (ecommerce-database):"
kubectl get pods -n ecommerce-database --no-headers | while read line; do
    echo "  🗄️ $line"
done

echo ""
echo "Frontend (ecommerce-frontend):"
kubectl get pods -n ecommerce-frontend --no-headers | while read line; do
    echo "  🌐 $line"
done

# Check log groups
echo ""
echo "📋 CloudWatch Log Groups:"
echo "-------------------------"
LOG_GROUPS=$(aws logs describe-log-groups \
    --region $REGION \
    --log-group-name-prefix "/aws/containerinsights/$CLUSTER_NAME" \
    --query 'logGroups[].logGroupName' \
    --output text 2>/dev/null || echo "")

if [ -n "$LOG_GROUPS" ]; then
    echo "$LOG_GROUPS" | tr '\t' '\n' | while read group; do
        if [ -n "$group" ]; then
            echo "  ✅ $group"
        fi
    done
else
    echo "  ⏳ Log groups still being created..."
fi

# Check metrics
echo ""
echo "📈 CloudWatch Metrics:"
echo "----------------------"
METRICS_COUNT=$(aws cloudwatch list-metrics \
    --region $REGION \
    --namespace AWS/ContainerInsights \
    --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
    --query 'length(Metrics)' \
    --output text 2>/dev/null || echo "0")

if [ "$METRICS_COUNT" -gt 0 ]; then
    echo "  ✅ $METRICS_COUNT Container Insights metrics available"
else
    echo "  ⏳ Metrics still being collected (takes 5-10 minutes initially)"
fi

echo ""
echo "🎯 Quick Access Links:"
echo "----------------------"
echo "📊 Container Insights:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#container-insights:infrastructure"
echo ""
echo "📈 Custom Dashboard:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards:name=ECommerce-Microservices-Dashboard"
echo ""
echo "🔍 Log Insights:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#logsV2:logs-insights"
echo ""
echo "💡 Next Steps:"
echo "  • Wait 5-10 minutes for metrics to appear in dashboard"
echo "  • Run './add-logs-to-dashboard.sh' to add log insights widget"
echo "  • Set up CloudWatch Alarms for critical metrics"
echo "  • Configure SNS notifications for alerts"
