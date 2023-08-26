#!/bin/bash

docker build -t password-rotation -f docker/password-rotation.Dockerfile .
docker run --rm --env-file .env password-rotation
