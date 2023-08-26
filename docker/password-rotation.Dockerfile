FROM python:3.10-bullseye

WORKDIR /app

COPY ./password-rotation-cronjob /app/password-rotation-cronjob
COPY ./.env /app/.env

RUN pip install -r password-rotation-cronjob/requirements.txt

ENTRYPOINT [ "python", "password-rotation-cronjob/password-rotation.py" ]
