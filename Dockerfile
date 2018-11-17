FROM alpine:3.8 AS build

ENV \
  CONSUL_TEMPLATE_VERSION=0.19.3 \
  CONSUL_TEMPLATE_SHA256=47b3f134144b3f2c6c1d4c498124af3c4f1a4767986d71edfda694f822eb7680

RUN \
  apk add --no-cache \
    curl \
    unzip \
  \
  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

FROM postgres:11.1-alpine

ENV \
  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  VAULT_ADDR= \
  VAULT_TOKEN= \
  \
  BACKUP_HOST= \
  BACKUP_PATH= \
  BACKUP_HOUR=0 \
  BACKUP_MINUTE=0 \
  BACKUP_IS_RANDOM_DELAY=1 \
  \
  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow

COPY --from=build /usr/local/bin/consul-template /usr/local/bin/consul-template
COPY backup.sh /usr/local/bin/backup.sh
COPY pgpass.template /root/pgpass.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
