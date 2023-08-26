#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <start|stop>"
    exit 1
fi

if [ "$1" == "start" ]; then
    echo "Starting KIND cluster..."
    if [ "$(kind get clusters)" == "kind" ]; then
        echo "KIND cluster is already running"
    else
        kind create cluster --config kind/cluster-config.yaml
    fi
    
    if [[ $(helm list --all-namespaces | grep ingress-controller) ]]; then
        echo "Ingress controller already deployed"
    else
        echo "Deploying metallb for LoadBalancer to get external IP"
        kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
        sleep 40
        kubectl apply -f kind/metallb-config.yaml

        echo "Deploying ingress controller"
        helm upgrade --install ingress-controller ingress-nginx/ingress-nginx -f kind/ingress-controller-values.yaml 2>&1 >/dev/null
    fi
    echo "KIND cluster started successfully."

elif [ "$1" == "stop" ]; then
    echo "Stopping KIND cluster..."
    kind delete cluster
    
    echo "KIND cluster stopped successfully."
else
    echo "Usage: $0 <start|stop>"
    exit 1
fi
