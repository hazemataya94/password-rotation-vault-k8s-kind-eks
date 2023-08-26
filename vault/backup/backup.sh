#!/bin/bash

set -o errtrace

CURRENT_DATE=$(date '+%Y-%m-%d')

backup_database() {

    BACKUP_FILE_NAME=${CURRENT_DATE}.sql.gz

    mysqldump --host="${DATABASE_HOST}" --user="${DATABASE_USERNAME}" --password="${DATABASE_PASSWORD}" --single-transaction --quick "${DATABASE_NAME}" | gzip > ${BACKUP_FILE_NAME}

    aws s3 cp ${BACKUP_FILE_NAME} s3://${AWS_BUCKET_NAME}/${AWS_BUCKET_DB_DIR}/${BACKUP_FILE_NAME}

    rm -f ${BACKUP_FILE_NAME}
}

backup_logs() {

    BACKUP_FILE_NAME=${CURRENT_DATE}.tar.gz

    cd ${LOGS_DIRECTORY}

    tar -czvf ${BACKUP_FILE_NAME} *.log

    aws s3 cp ${BACKUP_FILE_NAME} s3://${AWS_BUCKET_NAME}/${AWS_BUCKET_LOG_DIR}/${BACKUP_FILE_NAME}

    truncate -s 0 *.log

    rm -f ${BACKUP_FILE_NAME}
}

# cleanup function will run in case any error occures in the script
# TODO: change this function to send a discord alert in case of failure, it is very important
cleanup() {

  ERROR_CODE=$1
  ERROR_LINE=$2
  ERROR_COMMAND=$3
  
  echo "Exit with error code ${ERROR_CODE}, in line ${ERROR_LINE}, command: \"${ERROR_COMMAND}\""
  
  exit 0;
}

#run cleanup on exit
trap 'cleanup $? $LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]})' ERR

####################################
############ start main ############
####################################

echo "Backup database..."

backup_database

echo "Backup logs..."

backup_logs

echo "Done."
