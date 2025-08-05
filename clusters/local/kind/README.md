# Kind Cluster for GitOps Demo

This directory contains configuration and scripts for managing a Kind (Kubernetes in Docker) cluster for the GitOps demo.

## Files

- `cluster-config.yaml` - Kind cluster configuration for multi-node setup
- `manage-cluster.sh` - Script to manage cluster lifecycle
- `README.md` - This file

## Cluster Configuration

The cluster includes:
- **1 Control Plane Node**: Master node with API server
- **2 Worker Nodes**: Worker nodes for application workloads
- **Port Mappings**: 
  - Port 80/443 for Ingress Controller
  - Port 30080/30443 for NodePort services (ArgoCD)
- **Storage**: Local path provisioner for persistent volumes
- **Networking**: Standard CNI with custom pod/service subnets

## Quick Start

### Create the cluster:
```bash
./manage-cluster.sh setup
```

This will:
1. Create the multi-node Kind cluster
2. Install Ingress NGINX Controller
3. Install local storage provisioner
4. Load common Docker images

### Individual commands:
```bash
# Create cluster only
./manage-cluster.sh create

# Delete cluster
./manage-cluster.sh delete

# Show cluster info
./manage-cluster.sh info

# Install ingress controller
./manage-cluster.sh install-ingress

# Install storage provisioner
./manage-cluster.sh install-storage

# Load common images
./manage-cluster.sh load-images
```

## Accessing Services

### ArgoCD
After deploying ArgoCD:
```bash
# Access via NodePort
https://localhost:30443

# Or use port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Applications via Ingress
```bash
# Applications will be available at
http://localhost
```

## Cluster Specifications

- **Kubernetes Version**: v1.31.0
- **Nodes**: 1 control-plane + 2 workers
- **CNI**: Default Kind CNI (kindnet)
- **Storage Class**: local-path (default)
- **Ingress**: NGINX Ingress Controller

## Troubleshooting

### Check cluster status:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### View cluster logs:
```bash
kind export logs --name dev
```

### Reset cluster:
```bash
./manage-cluster.sh delete
./manage-cluster.sh setup
```
