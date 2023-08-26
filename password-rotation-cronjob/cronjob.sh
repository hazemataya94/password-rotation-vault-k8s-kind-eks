#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pip|freeze|run|create-role|deploy>"
    exit 1
fi

if [ "$1" == "pip" ]; then
    pip install -r password-rotation-cronjob/requirements.txt
elif [ "$1" == "freeze" ]; then
    pip freeze > password-rotation-cronjob/requirements.txt
elif [ "$1" == "run" ]; then
    python password-rotation-cronjob/password-rotation.py
elif [ "$1" == "create-role" ]; then
    python password-rotation-cronjob/create-app-role.py
elif [ "$1" == "deploy" ]; then
    if [[ $(kubectl get jobs | grep password-rotation) ]]; then
        echo "Deleting already existing job"
        kubectl delete -f password-rotation-cronjob/job.yaml
    fi
    kubectl apply -f password-rotation-cronjob/job.yaml
else
    echo "Usage: $0 <pip|freeze|run|create-role>"
    exit 1
fi
