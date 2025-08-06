#!/bin/bash

# Kind Cluster Management Script for GitOps Demo
# Manages local development cluster for ArgoCD and GitOps workflows

set -e

CLUSTER_NAME="dev"
CONFIG_FILE="dev-cluster-simple.yaml"

usage() {
    echo "Usage: $0 {create|delete|status|reset|logs}"
    echo ""
    echo "Commands:"
    echo "  create  - Create the Kind cluster"
    echo "  delete  - Delete the Kind cluster"
    echo "  status  - Show cluster status"
    echo "  reset   - Delete and recreate the cluster"
    echo "  logs    - Show cluster logs"
    echo ""
    exit 1
}

create_cluster() {
    echo "🚀 Creating Kind cluster '$CLUSTER_NAME'..."
    
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
        echo "⚠️  Cluster '$CLUSTER_NAME' already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            delete_cluster
        else
            echo "Aborted."
            exit 0
        fi
    fi
    
    echo "📋 Using config: $CONFIG_FILE"
    kind create cluster --config="$(dirname "$0")/$CONFIG_FILE"
    
    echo "⏳ Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    echo "📦 Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    echo "⏳ Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
    
    echo "🔧 Configuring ingress controller service for Kind..."
    kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec":{"type":"NodePort","ports":[{"name":"http","port":80,"protocol":"TCP","targetPort":"http","nodePort":30269},{"name":"https","port":443,"protocol":"TCP","targetPort":"https","nodePort":31186}]}}'
    
    echo "✅ Cluster created successfully!"
    echo ""
    echo "🔍 Cluster Info:"
    kubectl cluster-info --context kind-$CLUSTER_NAME
    echo ""
    echo "📋 Nodes:"
    kubectl get nodes -o wide
    echo ""
    echo "🌐 Port Mappings:"
    echo "  ArgoCD HTTP:  http://localhost:9080"
    echo "  ArgoCD HTTPS: https://localhost:9443" 
    echo "  HTTP Ingress: http://localhost:8080"
    echo "  HTTPS Ingress: https://localhost:8443"
}

delete_cluster() {
    echo "🗑️  Deleting Kind cluster '$CLUSTER_NAME'..."
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
        kind delete cluster --name="$CLUSTER_NAME"
        echo "✅ Cluster deleted successfully!"
    else
        echo "⚠️  Cluster '$CLUSTER_NAME' does not exist"
    fi
}

show_status() {
    echo "📊 Kind Clusters:"
    kind get clusters
    echo ""
    
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
        echo "🔍 Cluster '$CLUSTER_NAME' Details:"
        kubectl cluster-info --context kind-$CLUSTER_NAME
        echo ""
        echo "📋 Nodes:"
        kubectl get nodes -o wide --context kind-$CLUSTER_NAME
        echo ""
        echo "📦 System Pods:"
        kubectl get pods -A --context kind-$CLUSTER_NAME
    else
        echo "⚠️  Cluster '$CLUSTER_NAME' does not exist"
    fi
}

reset_cluster() {
    echo "🔄 Resetting cluster '$CLUSTER_NAME'..."
    delete_cluster
    sleep 2
    create_cluster
}

show_logs() {
    echo "📋 Cluster Logs for '$CLUSTER_NAME':"
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
        kind export logs --name="$CLUSTER_NAME" /tmp/kind-logs-$CLUSTER_NAME
        echo "Logs exported to: /tmp/kind-logs-$CLUSTER_NAME"
        echo ""
        echo "Recent kubelet logs from control-plane:"
        docker logs ${CLUSTER_NAME}-control-plane 2>&1 | tail -20
    else
        echo "⚠️  Cluster '$CLUSTER_NAME' does not exist"
    fi
}

# Main script logic
case "${1:-}" in
    create)
        create_cluster
        ;;
    delete)
        delete_cluster
        ;;
    status)
        show_status
        ;;
    reset)
        reset_cluster
        ;;
    logs)
        show_logs
        ;;
    *)
        usage
        ;;
esac
