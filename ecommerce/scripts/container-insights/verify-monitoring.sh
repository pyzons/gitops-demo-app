#!/bin/bash

# Verify Container Insights and Monitoring Setup
# This script checks if all monitoring components are working correctly

set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NAMESPACE="amazon-cloudwatch"

echo "🔍 Verifying Container Insights Setup"
echo "====================================="
echo ""

# Check CloudWatch namespace
echo "📁 Checking CloudWatch namespace..."
if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
    echo "✅ CloudWatch namespace exists"
else
    echo "❌ CloudWatch namespace not found"
    exit 1
fi

# Check CloudWatch Agent
echo ""
echo "🤖 Checking CloudWatch Agent..."
AGENT_PODS=$(kubectl get pods -n $NAMESPACE -l name=cloudwatch-agent --no-headers | wc -l)
AGENT_READY=$(kubectl get pods -n $NAMESPACE -l name=cloudwatch-agent --no-headers | grep Running | wc -l)

echo "CloudWatch Agent pods: $AGENT_PODS total, $AGENT_READY running"
if [ "$AGENT_PODS" -gt 0 ] && [ "$AGENT_READY" -eq "$AGENT_PODS" ]; then
    echo "✅ CloudWatch Agent is healthy"
else
    echo "❌ CloudWatch Agent issues detected"
    kubectl get pods -n $NAMESPACE -l name=cloudwatch-agent
fi

# Check Fluent Bit
echo ""
echo "📝 Checking Fluent Bit..."
FLUENT_PODS=$(kubectl get pods -n $NAMESPACE -l k8s-app=fluent-bit --no-headers | wc -l)
FLUENT_READY=$(kubectl get pods -n $NAMESPACE -l k8s-app=fluent-bit --no-headers | grep Running | wc -l)

echo "Fluent Bit pods: $FLUENT_PODS total, $FLUENT_READY running"
if [ "$FLUENT_PODS" -gt 0 ] && [ "$FLUENT_READY" -eq "$FLUENT_PODS" ]; then
    echo "✅ Fluent Bit is healthy"
else
    echo "❌ Fluent Bit issues detected"
    kubectl get pods -n $NAMESPACE -l k8s-app=fluent-bit
fi

# Check application pods
echo ""
echo "🛍️ Checking E-Commerce Application Pods..."

# Backend services
echo "Backend Services:"
kubectl get pods -n ecommerce-backend -o wide

# Database
echo ""
echo "Database:"
kubectl get pods -n ecommerce-database -o wide

# Frontend
echo ""
echo "Frontend:"
kubectl get pods -n ecommerce-frontend -o wide

# Check metrics availability
echo ""
echo "📊 Checking CloudWatch metrics availability..."
echo "Waiting for metrics to be available (this may take a few minutes)..."

# Wait a bit for metrics to be collected
sleep 30

# Check if metrics are being sent
METRICS_CHECK=$(aws cloudwatch list-metrics \
    --region $REGION \
    --namespace AWS/ContainerInsights \
    --dimensions Name=ClusterName,Value=$CLUSTER_NAME \
    --query 'Metrics[0].MetricName' \
    --output text 2>/dev/null || echo "NONE")

if [ "$METRICS_CHECK" != "NONE" ] && [ "$METRICS_CHECK" != "None" ]; then
    echo "✅ CloudWatch metrics are being collected"
else
    echo "⏳ Metrics not yet available (may take 5-10 minutes for first metrics)"
fi

# Check log groups
echo ""
echo "📋 Checking CloudWatch Log Groups..."
LOG_GROUPS=$(aws logs describe-log-groups \
    --region $REGION \
    --log-group-name-prefix "/aws/containerinsights/$CLUSTER_NAME" \
    --query 'logGroups[].logGroupName' \
    --output text 2>/dev/null || echo "")

if [ -n "$LOG_GROUPS" ]; then
    echo "✅ Log groups found:"
    echo "$LOG_GROUPS" | tr '\t' '\n' | sed 's/^/   • /'
else
    echo "⏳ Log groups not yet created (may take a few minutes)"
fi

echo ""
echo "🎉 Monitoring Verification Complete!"
echo ""
echo "📊 Access your monitoring:"
echo "   • Container Insights: https://console.aws.amazon.com/cloudwatch/home?region=$REGION#container-insights:infrastructure"
echo "   • Custom Dashboard: https://console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards:name=ECommerce-Microservices-Dashboard"
echo "   • Log Insights: https://console.aws.amazon.com/cloudwatch/home?region=$REGION#logsV2:logs-insights"
echo ""
echo "💡 Tips:"
echo "   • Metrics may take 5-10 minutes to appear initially"
echo "   • Use Log Insights to query application logs"
echo "   • Set up CloudWatch Alarms for proactive monitoring"
