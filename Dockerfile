FROM python:3.12.2-alpine3.19

RUN apk update && apk add --no-cache bash python3 py3-pip shadow && \
     pip3 install --break-system-packages --upgrade pip && \
     pip3 install --break-system-packages awscli==1.32.108 && \
     ln -sf /usr/bin/python3 /usr/bin/python && \
     rm -rf /var/cache/apk/*

RUN adduser -u 1000 jenkins -D -s /bin/bash

COPY *.sh /

RUN chmod +x /*.sh


CMD ["sh", "-c", "/run.sh"]
