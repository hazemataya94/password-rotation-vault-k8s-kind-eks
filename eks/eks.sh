#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <start|stop>"
    exit 1
fi

if [ "$1" == "start" ]; then
    echo "Starting EKS cluster..."
    if [ "$(kubectl config get-contexts | grep codejam)" == "codejam" ]; then
        echo "EKS cluster is already running"
    else
        eksctl create cluster -f eks/codejam-cluster.yaml
    fi
    
    echo "Deploying ingress controller"
    helm upgrade --install ingress-controller ingress-nginx/ingress-nginx -f eks/ingress-controller-values.yaml 2>&1 >/dev/null
    echo "EKS cluster started successfully."

elif [ "$1" == "stop" ]; then
    echo "Stopping EKS cluster..."
    eksctl delete cluster -f eks/codejam-cluster.yaml
else
    echo "Usage: $0 <start|stop>"
    exit 1
fi
