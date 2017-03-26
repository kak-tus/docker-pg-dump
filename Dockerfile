FROM postgres:9.6

ENV CONSUL_TEMPLATE_VERSION=0.18.0
ENV CONSUL_TEMPLATE_SHA256=f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip ca-certificates cron rsync \

  && rm -rf /etc/cron.daily/* \
  && rm -rf /etc/cron.hourly/* \
  && rm -rf /etc/cron.monthly/* \
  && rm -rf /etc/cron.weekly/* \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && apt-get purge -y curl unzip ca-certificates \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

ENV BACKUP_HOST=

ENV SET_CONTAINER_TIMEZONE=true
ENV CONTAINER_TIMEZONE=Europe/Moscow

ENV BACKUP_TARGET_USER=
ENV BACKUP_TARGET_HOST=
ENV BACKUP_TARGET_MODULE=
ENV BACKUP_TARGET_PATH=

COPY backup /etc/cron.d/backup
COPY backup.sh /usr/local/bin/backup.sh
COPY pgpass.template /root/pgpass.template
COPY rsyncd_password_file.template /root/rsyncd_password_file.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
