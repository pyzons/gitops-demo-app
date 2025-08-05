#!/bin/bash

# Complete Container Insights and Monitoring Setup
# This script sets up comprehensive monitoring for the entire e-commerce application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Complete E-Commerce Monitoring Setup"
echo "========================================"
echo ""
echo "This script will:"
echo "  1. Enable Container Insights"
echo "  2. Deploy CloudWatch Agent and Fluent Bit"
echo "  3. Create custom dashboard"
echo "  4. Verify the setup"
echo ""

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "🔧 Step 1: Enabling Container Insights..."
bash "$SCRIPT_DIR/enable-container-insights.sh"

echo ""
echo "🎨 Step 2: Creating Custom Dashboard..."
bash "$SCRIPT_DIR/create-dashboard.sh"

echo ""
echo "🔍 Step 3: Verifying Setup..."
bash "$SCRIPT_DIR/verify-monitoring.sh"

echo ""
echo "🎉 Complete Monitoring Setup Finished!"
echo ""
echo "📊 Your e-commerce application now has comprehensive monitoring including:"
echo "   • Real-time metrics for all microservices"
echo "   • Centralized logging from all containers"
echo "   • Custom dashboard for business insights"
echo "   • Infrastructure and application performance monitoring"
echo ""
echo "🔗 Quick Access Links:"
echo "   • Container Insights: https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#container-insights:infrastructure"
echo "   • Custom Dashboard: https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=ECommerce-Microservices-Dashboard"
echo "   • Log Insights: https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:logs-insights"
echo ""
echo "💡 Next Steps:"
echo "   • Set up CloudWatch Alarms for critical metrics"
echo "   • Configure SNS notifications for alerts"
echo "   • Create additional custom dashboards for specific teams"
echo "   • Use X-Ray for distributed tracing (if needed)"
