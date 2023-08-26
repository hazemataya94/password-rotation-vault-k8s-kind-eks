#!/bin/bash
set -e

CHART_NAME="vault"
CHART_PATH="./vault/hc-vault"
K8S_NAMESPACE="default"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <start|stop>"
    exit 1
fi

if [ "$1" == "start" ]; then
    # Start Vault chart
    echo "Starting Vault chart..."
    helm upgrade --install -n ${K8S_NAMESPACE} ${CHART_NAME} ${CHART_PATH}
    echo "Vault started successfully."
elif [ "$1" == "stop" ]; then
    # Stop Vault chart
    echo "Stopping Vault chart..."
    helm uninstall -n ${K8S_NAMESPACE} ${CHART_NAME}
    echo "Vault stopped successfully."
else
    echo "Usage: $0 <start|stop>"
    exit 1
fi
