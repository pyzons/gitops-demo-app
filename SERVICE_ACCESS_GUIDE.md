# 🔗 Service Access Guide

This document provides the correct access information for all services in the GitOps Demo environment.

## 📊 **Service URLs & Credentials**

### 🎯 **ArgoCD GitOps Platform**
- **HTTP URL**: http://localhost:9080
- **HTTPS URL**: https://localhost:9443
- **Username**: `admin`
- **Password**: Get with: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### 📈 **Grafana Dashboards**
- **URL**: http://localhost:3000
- **Username**: `admin`
- **Password**: `admin123`
- **Dashboards**: 
  - Kubernetes Cluster Overview
  - Node Exporter Metrics
  - ArgoCD GitOps Dashboard
  - Prometheus Monitoring

### 🔍 **Prometheus Metrics**
- **URL**: http://localhost:9090
- **Authentication**: None required
- **Purpose**: Raw metrics collection and querying

### 🌐 **Ingress Controller**
- **HTTP URL**: http://localhost:8080
- **HTTPS URL**: https://localhost:8443
- **Purpose**: Application ingress traffic

## 🔌 **Port Mapping Reference**

| Service | Internal Port | NodePort | Localhost | Access URL |
|---------|--------------|----------|-----------|------------|
| ArgoCD HTTP | 80 | 30080 | 9080 | http://localhost:9080 |
| ArgoCD HTTPS | 443 | 30443 | 9443 | https://localhost:9443 |
| Prometheus | 9090 | 31000 | 9090 | http://localhost:9090 |
| Grafana | 3000 | 31001 | 3000 | http://localhost:3000 |
| Ingress HTTP | 80 | 30269 | 8080 | http://localhost:8080 |
| Ingress HTTPS | 443 | 31186 | 8443 | https://localhost:8443 |

## 🚀 **Quick Access Commands**

### Get ArgoCD Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Test Service Health
```bash
# Test Grafana
curl -s http://localhost:3000/api/health

# Test Prometheus  
curl -s http://localhost:9090/-/healthy

# Test ArgoCD
curl -s -k https://localhost:9443/healthz
```

### List Available Dashboards
```bash
make list-dashboards
```

### Verify All Services
```bash
make test-observability
make verify-dashboards
```

## 🎯 **Navigation Guide**

### **ArgoCD (GitOps Management)**
1. Open http://localhost:9080
2. Login with admin + password from command above
3. Create applications, sync deployments
4. Monitor GitOps workflows

### **Grafana (Monitoring Dashboards)**  
1. Open http://localhost:3000
2. Login with admin/admin123
3. Navigate to Dashboards → Browse
4. Select any dashboard to view metrics

### **Prometheus (Raw Metrics)**
1. Open http://localhost:9090
2. Use the query interface to explore metrics
3. View targets and configuration
4. Query custom metrics

## ⚠️ **Common Issues**

### ArgoCD Not Accessible
```bash
# Check if ArgoCD is running
kubectl get pods -n argocd

# Check service status
kubectl get svc argocd-server -n argocd

# Verify port mapping
docker port dev-control-plane
```

### Grafana Dashboard Not Loading
```bash
# Restart Grafana
make dashboards

# Check dashboard files
make verify-dashboards
```

### Prometheus No Data
```bash
# Check targets
curl -s http://localhost:9090/api/v1/targets

# Test observability
make test-observability
```

## 🔄 **Service Management**

### Complete Setup
```bash
make all  # Everything from scratch
```

### Individual Services  
```bash
make observability     # Deploy monitoring stack
make dashboards       # Update dashboards
make test-observability  # Verify health
```

### Cleanup
```bash
make clean-all        # Remove everything
make kind-reset       # Reset cluster
```

This guide ensures you have the correct access information for all services in your GitOps environment! 🎉
