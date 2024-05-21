#!/usr/bin/env bash

chown -R 1000:1000 /dumps/ # Setting the permission for the jenkins to store dumps

cd /dumps || exit
while true; do
    DATE_TODAY=$(date +"%Y_%m_%d")
    for FILE in *; do
        if [ -d $FILE ]; then
            # directory: move as is
            DIR=$(basename $FILE)
            aws s3 mv $FILE s3://$S3bucket/$DIR --recursive --acl bucket-owner-full-control
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump dir $FILE to S3 bucket $S3bucket"
            fi
        elif [ -f $FILE ]; then
            # file: move to a directory named with the file timestamp
            TIMESTAMP=$(date -r $FILE +"%Y_%m_%d_%H_%M_%S")
            FILENAME="${FILE%%.*}"
            FILE_EXTENSION="${FILE#*.}"
            DESTINATION_LOCATION="s3://${S3bucket}/${DATE_TODAY}/${FILENAME}_${EKS_CLUSTER_NAME}_${TIMESTAMP}.${FILE_EXTENSION}"
            aws s3 mv $FILE $DESTINATION_LOCATION --acl bucket-owner-full-control
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump file $FILE to S3 bucket $S3bucket"
            fi
        fi
    done
    sleep 60s
done
