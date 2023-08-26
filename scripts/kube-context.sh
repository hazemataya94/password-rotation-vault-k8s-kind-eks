#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <local|cloud>"
    exit 1
fi

if [ "$1" == "local" ]; then
    kubectl config use-context kind
    echo "Kubectl context is set to kind-kind"
elif [ "$1" == "cloud" ]; then
    kubectl config use-context Hazem@codejam.eu-central-1.eksctl.io
    echo "Kubectl context is set to eks"
else
    echo "Usage: $0 <local|cloud>"
    exit 1
fi
