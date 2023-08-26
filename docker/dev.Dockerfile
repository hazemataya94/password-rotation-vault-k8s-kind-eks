FROM python:3.10-bullseye

WORKDIR /app
COPY .bashrc /root/.bashrc

# Used for development and debugging the container
ENTRYPOINT [ "sleep", "infinity" ]
