#!/bin/bash

# Create Custom CloudWatch Dashboard for E-Commerce Microservices
# This script creates a comprehensive dashboard for monitoring all microservices

set -e

DASHBOARD_NAME="ECommerce-Microservices-Dashboard"
REGION="us-west-2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📊 Creating Custom CloudWatch Dashboard"
echo "======================================="
echo "Dashboard Name: $DASHBOARD_NAME"
echo "Region: $REGION"
echo ""

# Create the dashboard
echo "🎨 Creating dashboard..."
aws cloudwatch put-dashboard \
    --region $REGION \
    --dashboard-name "$DASHBOARD_NAME" \
    --dashboard-body file://"$SCRIPT_DIR/ecommerce-dashboard.json"

echo "✅ Dashboard created successfully!"
echo ""
echo "🔗 Access your dashboard:"
echo "https://console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards:name=$DASHBOARD_NAME"
echo ""
echo "📈 Your dashboard includes:"
echo "   • Cluster-wide resource utilization"
echo "   • Individual microservice metrics (CPU/Memory)"
echo "   • Database performance metrics"
echo "   • Frontend application metrics"
echo "   • Real-time application logs"
