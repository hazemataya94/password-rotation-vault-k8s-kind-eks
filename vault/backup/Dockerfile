FROM mariadb:10.5

RUN apt update && apt install -y awscli

COPY --chmod=0500 ./backup.sh ./backup.sh

ENTRYPOINT ["./backup.sh"]
