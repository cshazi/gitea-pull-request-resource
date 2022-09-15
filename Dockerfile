FROM alpine:3.16

RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    openssh-client

COPY scripts/ /opt/resource/
RUN chmod +x /opt/resource/*
