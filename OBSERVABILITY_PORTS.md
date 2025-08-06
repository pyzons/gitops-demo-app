# Observability Stack Port Configuration

## Current Issue
The observability services (Prometheus and Grafana) are configured with NodePorts that are not mapped to host ports in the current Kind cluster configuration.

## Current Cluster Port Mappings
The existing cluster only has these port mappings:
- `localhost:9080` → `30080` (ArgoCD)
- `localhost:9443` → `30443` (ArgoCD HTTPS)
- `localhost:9080` → `30080` (ArgoCD HTTP)
- `localhost:9443` → `30443` (ArgoCD HTTPS)  
- `localhost:9090` → `31000` (Prometheus)
- `localhost:3000` → `31001` (Grafana)
- `localhost:8080` → `30269` (Ingress HTTP)
- `localhost:8443` → `31186` (Ingress HTTPS)

## Observability Services Current State
- **Prometheus**: NodePort `31000` (NOT mapped to host)
- **Grafana**: NodePort `31001` (NOT mapped to host)

## Solution Options

### Option 1: Recreate Cluster (Recommended)
To get external access to monitoring services, recreate the cluster with updated port mappings:

```bash
# Delete current cluster
cd kind
./cluster-manager.sh delete

# Recreate with new port mappings (already updated in config)
./cluster-manager.sh create

# Redeploy everything
cd ..
./setup.sh
./deploy-observability.sh
```

After recreation, you'll have:
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000

### Option 2: Keep Current Cluster (Port Forward)
If you want to keep the current cluster, access services via port forwarding:

```bash
# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090

# Access Grafana (in another terminal)
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

## Updated Configuration Files

The following files have been updated with proper port mappings:
- `kind/dev-cluster-simple.yaml` - Added monitoring ports
- `kind/dev-cluster.yaml` - Added monitoring ports  
- `deploy-observability.sh` - Updated access information

## Port Allocation Summary

After cluster recreation, all services will be accessible:

| Service | Internal Port | NodePort | Host Port | External URL |
|---------|---------------|----------|-----------|--------------|
| ArgoCD HTTP | 80 | 30080 | 9080 | http://localhost:9080 |
| ArgoCD HTTPS | 443 | 30443 | 9443 | https://localhost:9443 |
| ArgoCD HTTPS | 8443 | 30443 | 9443 | https://localhost:9443 |
| Ingress HTTP | 80 | 30269 | 8080 | http://localhost:8080 |
| Ingress HTTPS | 443 | 31186 | 8443 | https://localhost:8443 |
| Prometheus | 9090 | 31000 | 9090 | http://localhost:9090 |
| Grafana | 3000 | 31001 | 3000 | http://localhost:3000 |

## Current Workaround
The monitoring stack is fully functional within the cluster. All internal communication works:
- Prometheus is scraping metrics from all targets
- Grafana can connect to Prometheus as a data source
- All health checks pass

Only external browser access requires either cluster recreation or port forwarding.
