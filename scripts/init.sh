#!/bin/bash
set -e

echo "Set pre-commit hook"
cp ./scripts/pre-commit ./.git/hooks/

echo "Add helm repos"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add vault https://helm.releases.hashicorp.com
helm repo add teamcity-charts https://nefelim4ag.github.io/teamcity-charts/
helm repo update

echo "Install helm dependencies"
cd ./vault/hc-vault && helm dep build && cd -

echo "Project has be initialized"
