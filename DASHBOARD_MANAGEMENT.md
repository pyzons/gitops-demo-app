# Grafana Dashboard Management

This document explains how to manage Grafana dashboards using the Makefile workflow.

## Overview

The GitOps Demo now includes comprehensive Grafana dashboard management through Make commands, providing a consistent and automated approach to deploying, updating, and managing monitoring dashboards.

## Available Dashboard Commands

### Quick Reference

```bash
# Deploy/update dashboards
make dashboards

# List available dashboards  
make list-dashboards

# Verify dashboard functionality
make verify-dashboards

# Update existing dashboards (alias)
make update-dashboards
```

### Command Details

#### `make dashboards`
- **Purpose**: Deploy or update Grafana dashboards
- **What it does**:
  - Applies dashboard ConfigMaps to Kubernetes
  - Restarts Grafana to load new configurations
  - Waits for deployment to be ready
  - Provides access information

#### `make list-dashboards`
- **Purpose**: List all available dashboards
- **What it does**:
  - Queries Grafana API for loaded dashboards
  - Shows dashboard titles and URLs
  - Provides quick access information

#### `make verify-dashboards`
- **Purpose**: Comprehensive dashboard verification
- **What it does**:
  - Checks Grafana health status
  - Verifies dashboard file mounting
  - Lists available dashboards with features
  - Provides access instructions

#### `make update-dashboards`
- **Purpose**: Alias for `make dashboards`
- **Use case**: Semantic clarity when updating existing dashboards

## Dashboard Configuration Files

### Location
```
observability/prometheus/
├── grafana-dashboards.yaml         # Dashboard JSON content
├── grafana-dashboards-config.yaml  # Provisioning configuration
└── grafana.yaml                     # Grafana deployment
```

### Available Dashboards

1. **Kubernetes Cluster Overview**
   - General cluster health and metrics
   - Node count, pod status, resource utilization
   - URL: `/d/kubernetes-cluster/kubernetes-cluster-overview`

2. **Node Exporter Metrics**
   - Detailed system metrics from all nodes
   - CPU, memory, disk, network performance
   - URL: `/d/node-exporter/node-exporter-metrics`

3. **ArgoCD GitOps Dashboard**
   - GitOps application status and health
   - Sync status and deployment tracking
   - URL: `/d/argocd-gitops/argocd-gitops-dashboard`

4. **Prometheus Monitoring**
   - Monitoring stack performance
   - Target discovery and query metrics
   - URL: `/d/prometheus-monitoring/prometheus-monitoring`

## Integration with Observability Stack

The dashboard management is integrated into the main observability workflow:

```bash
# Complete observability setup (includes dashboards)
make observability

# Full GitOps environment with monitoring
make all
```

When you run `make observability`, dashboards are automatically:
1. Deployed with the monitoring stack
2. Configured in Grafana
3. Made available immediately

## Dashboard Development Workflow

### 1. Adding New Dashboards

1. **Edit the ConfigMap**:
   ```bash
   # Edit the dashboard configuration
   vim observability/prometheus/grafana-dashboards.yaml
   ```

2. **Add your dashboard JSON**:
   ```yaml
   data:
     my-new-dashboard.json: |
       {
         "id": null,
         "uid": "my-dashboard",
         "title": "My Custom Dashboard",
         # ... dashboard JSON
       }
   ```

3. **Deploy the changes**:
   ```bash
   make dashboards
   ```

### 2. Updating Existing Dashboards

1. **Modify dashboard JSON** in `grafana-dashboards.yaml`
2. **Apply changes**:
   ```bash
   make update-dashboards
   ```

### 3. Testing Dashboard Changes

```bash
# Verify dashboards are working
make verify-dashboards

# List all available dashboards
make list-dashboards

# Test the full observability stack
make test-observability
```

## Benefits of Makefile-Based Dashboard Management

### ✅ **Consistency**
- All observability components managed through unified interface
- Same commands work across different environments
- Predictable deployment process

### ✅ **Automation** 
- Automated dashboard deployment and updates
- Integrated health checks and verification
- Error handling and rollback capabilities

### ✅ **Version Control**
- Dashboard configurations tracked in Git
- Change history and rollback capabilities
- Collaborative dashboard development

### ✅ **CI/CD Ready**
- Commands can be integrated into pipelines
- Automated testing and validation
- Environment-specific configurations

### ✅ **Documentation**
- Self-documenting through `make help`
- Clear command purposes and usage
- Integrated verification and status checks

## Access Information

- **Grafana URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin123
- **Dashboard Access**: Dashboards → Browse
- **ArgoCD URL**: http://localhost:9080
- **Prometheus URL**: http://localhost:9090

## Troubleshooting

### Dashboard Not Appearing
```bash
# Check if dashboards are deployed
kubectl get configmap grafana-dashboards -n monitoring

# Verify Grafana is running
kubectl get pods -n monitoring -l app=grafana

# Restart Grafana to reload dashboards
make dashboards
```

### Connection Issues
```bash
# Check cluster connectivity
make check-cluster

# Verify observability stack health
make test-observability

# Full verification
make verify-dashboards
```

### Dashboard JSON Errors
```bash
# Check Grafana logs for JSON validation errors
kubectl logs -n monitoring deployment/grafana | grep -i error

# Validate JSON format
cat observability/prometheus/grafana-dashboards.yaml | yq '.data'
```

## Best Practices

1. **Use the Makefile**: Always use `make dashboards` instead of manual kubectl commands
2. **Test Changes**: Run `make verify-dashboards` after updates
3. **Version Control**: Commit dashboard changes to Git
4. **Documentation**: Update dashboard descriptions when adding new ones
5. **Validation**: Use `make validate` to check manifest syntax before deployment

This workflow ensures consistent, reliable, and maintainable dashboard management as part of your GitOps observability stack.
