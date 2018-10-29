FROM golang:alpine AS builder
ARG GOARCH=amd64

COPY . /go/src/github.com/JohannWeging/setup-mosquitto
WORKDIR /go/src/github.com/JohannWeging/setup-mosquitto

RUN set -x \
 && GOARCH=${GOARCH} go install github.com/JohannWeging/setup-mosquitto

ARG ARCH_SUFFIX
FROM johannweging/base-alpine:latest${ARCH_SUFFIX}

ENV CONFIG_FILE=/etc/mosquitto/mosquitto.conf MQ_PASSWORD_FILE=/etc/mosquitto/pwfile \
    MQ_PERSISTENCE_LOCATION=/var/lib/mosquitto/ MQ_PERSISTENCE_FILE=mosquitto.db

COPY --from=builder /go/bin/setup-mosquitto /usr/bin
COPY run.sh /run.sh

RUN set -x \
 && apk add --update --no-cache mosquitto \
 && chmod +x /run.sh

EXPOSE 1883

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/run.sh"]