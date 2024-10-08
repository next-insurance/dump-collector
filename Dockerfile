ARG REPO_URL="ecr-dns-redirect.nextinsurance.io"
FROM ${REPO_URL}/docker-hub/library/python:3.12.6-alpine3.20

RUN apk update && apk add --no-cache bash python3 py3-pip shadow && \
     pip3 install --break-system-packages --upgrade pip && \
     pip3 install --break-system-packages awscli==1.35.1 && \
     rm -rf /var/cache/apk/*

RUN adduser -u 1000 jenkins -D -s /bin/bash

COPY *.sh /

RUN chmod +x /*.sh


CMD ["sh", "-c", "/run.sh"]
