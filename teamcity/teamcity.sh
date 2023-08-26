#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <start|stop>"
    exit 1
fi

if [ "$1" == "start" ]; then
    echo "Starting TeamCity..."
    cd teamcity && mkdir -p buildserver_pgdata && docker-compose up -d
elif [ "$1" == "stop" ]; then
    echo "Stopping TeamCity.."
    cd teamcity && docker-compose down
else
    echo "Usage: $0 <start|stop>"
    exit 1
fi
