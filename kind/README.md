# Kind Development Cluster

This directory contains configuration for creating a local Kubernetes cluster using Kind (Kubernetes in Docker) for GitOps development and testing.

## Cluster Configuration

- **Cluster Name**: `dev`
- **Kubernetes Version**: `v1.33.1`
- **Nodes**: 1 control-plane + 2 worker nodes
- **CNI**: Default (kindnet)

## Port Mappings

The cluster exposes the following ports on localhost:

| Service | Port | URL |
|---------|------|-----|
| ArgoCD UI | 8080 | http://localhost:8080 |
| ArgoCD HTTPS | 8443 | https://localhost:8443 |
| Grafana | 3000 | http://localhost:3000 |
| Prometheus | 9090 | http://localhost:9090 |
| HTTP Ingress | 80 | http://localhost:80 |
| HTTPS Ingress | 443 | https://localhost:443 |

## Quick Start

### Using Makefile (Recommended)
```bash
# Create cluster
make kind-create

# Check status
make kind-status

# Install ArgoCD
make install

# Delete cluster
make kind-delete
```

### Using Script Directly
```bash
# Create cluster
./kind/cluster-manager.sh create

# Check status
./kind/cluster-manager.sh status

# Delete cluster
./kind/cluster-manager.sh delete
```

## Node Configuration

- **Control Plane**: Runs Kubernetes API server, etcd, and scheduler
- **Worker Node 1**: Labeled with `workload-type=applications` for app workloads
- **Worker Node 2**: Labeled with `workload-type=monitoring` for monitoring stack

## Features Enabled

- **ServerSideApply**: Better GitOps experience with kubectl
- **EphemeralContainers**: Debugging support
- **Custom networking**: Optimized pod and service subnets

## Troubleshooting

### Check cluster health
```bash
kubectl get nodes
kubectl get pods -A
```

### View cluster logs
```bash
make kind-logs
# or
./kind/cluster-manager.sh logs
```

### Reset cluster
```bash
make kind-reset
# or
./kind/cluster-manager.sh reset
```

## Prerequisites

- Docker installed and running
- Kind installed (`go install sigs.k8s.io/kind@latest`)
- kubectl installed
