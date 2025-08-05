# Container Insights for E-Commerce Microservices

This directory contains scripts to enable comprehensive monitoring for your e-commerce Kubernetes application using AWS Container Insights.

## 📊 What You Get

- **Real-time Metrics**: CPU, memory, network, and disk utilization for all microservices
- **Centralized Logging**: All container logs aggregated in CloudWatch
- **Custom Dashboard**: Business-focused view of your application performance
- **Infrastructure Monitoring**: Node and cluster-level insights
- **Application Performance**: Service-specific metrics and health monitoring

## 🚀 Quick Start

Run the complete setup with one command:

```bash
./setup-complete-monitoring.sh
```

## 📁 Files Overview

### Core Scripts
- `setup-complete-monitoring.sh` - **Main script** - runs everything
- `enable-container-insights.sh` - Enables Container Insights and deploys agents
- `create-dashboard.sh` - Creates custom CloudWatch dashboard
- `verify-monitoring.sh` - Verifies the monitoring setup

### Configuration Files
- `ecommerce-dashboard.json` - Custom dashboard configuration
- `README.md` - This documentation

## 🔧 Individual Components

### 1. Enable Container Insights
```bash
./enable-container-insights.sh
```
This script:
- Creates CloudWatch namespace
- Sets up IAM roles and service accounts
- Deploys CloudWatch Agent for metrics collection
- Deploys Fluent Bit for log collection

### 2. Create Custom Dashboard
```bash
./create-dashboard.sh
```
Creates a comprehensive dashboard showing:
- Cluster overview metrics
- Individual microservice performance
- Database metrics
- Frontend application metrics
- Real-time application logs

### 3. Verify Setup
```bash
./verify-monitoring.sh
```
Checks:
- All monitoring pods are running
- Metrics are being collected
- Log groups are created
- Application pods are healthy

## 📈 Monitoring Coverage

### Microservices Monitored
- **User Service** (ecommerce-backend namespace)
- **Product Service** (ecommerce-backend namespace)
- **Order Service** (ecommerce-backend namespace)
- **MongoDB Database** (ecommerce-database namespace)
- **Frontend Application** (ecommerce-frontend namespace)

### Metrics Collected
- CPU utilization per pod/service
- Memory utilization per pod/service
- Network I/O
- Disk utilization
- Pod restart counts
- Container status

### Logs Collected
- Application logs from all containers
- System logs from nodes
- Kubernetes events
- Container stdout/stderr

## 🔗 Access Your Monitoring

After setup, access your monitoring through:

1. **Container Insights Overview**
   - https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#container-insights:infrastructure

2. **Custom E-Commerce Dashboard**
   - https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=ECommerce-Microservices-Dashboard

3. **Log Insights for Querying Logs**
   - https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:logs-insights

## 💡 Best Practices

### Setting Up Alerts
Create CloudWatch Alarms for:
- High CPU utilization (>80%)
- High memory utilization (>85%)
- Pod restart frequency
- Application error rates

### Log Analysis
Use CloudWatch Logs Insights to:
- Track error patterns
- Monitor API response times
- Analyze user behavior
- Debug application issues

### Cost Optimization
- Set log retention policies
- Use metric filters to reduce noise
- Monitor CloudWatch costs in billing

## 🛠️ Troubleshooting

### Common Issues

1. **Metrics not appearing**
   - Wait 5-10 minutes for initial metrics
   - Check CloudWatch Agent pods are running
   - Verify IAM permissions

2. **Logs not showing**
   - Check Fluent Bit pods status
   - Verify log group creation
   - Check application is writing to stdout/stderr

3. **Dashboard empty**
   - Ensure metrics are being collected
   - Check pod names match dashboard configuration
   - Verify namespace names are correct

### Debug Commands
```bash
# Check monitoring pods
kubectl get pods -n amazon-cloudwatch

# Check pod logs
kubectl logs -n amazon-cloudwatch -l name=cloudwatch-agent
kubectl logs -n amazon-cloudwatch -l k8s-app=fluent-bit

# Check application pods
kubectl get pods --all-namespaces | grep ecommerce
```

## 📊 Sample Queries

### Log Insights Queries

**Find errors in backend services:**
```
fields @timestamp, kubernetes.namespace_name, kubernetes.pod_name, log
| filter kubernetes.namespace_name = "ecommerce-backend"
| filter log like /error/i
| sort @timestamp desc
```

**Monitor API response times:**
```
fields @timestamp, kubernetes.pod_name, log
| filter kubernetes.namespace_name = "ecommerce-backend"
| filter log like /response_time/
| sort @timestamp desc
```

## 🔄 Maintenance

### Regular Tasks
- Review and adjust log retention policies
- Update dashboard based on new requirements
- Monitor CloudWatch costs
- Set up additional alarms as needed

### Updates
- CloudWatch Agent updates automatically
- Dashboard can be modified by editing `ecommerce-dashboard.json`
- Scripts can be re-run safely for updates

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review AWS CloudWatch documentation
3. Check EKS Container Insights documentation
4. Verify your AWS permissions and quotas
