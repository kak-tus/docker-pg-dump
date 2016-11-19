FROM postgres:9.6

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

ENV BACKUP_HOST=
ENV SET_CONTAINER_TIMEZONE=true
ENV CONTAINER_TIMEZONE=Europe/Moscow

COPY backup /etc/cron.d/backup
COPY backup.sh /usr/local/bin/backup.sh
COPY pgpass.template /root/pgpass.template
COPY consul-template_0.16.0_SHA256SUMS /usr/local/bin/consul-template_0.16.0_SHA256SUMS
COPY rsyncd_password_file.template /root/rsyncd_password_file.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip ca-certificates cron rsync \

  && rm -rf /etc/cron.daily/* \
  && rm -rf /etc/cron.hourly/* \
  && rm -rf /etc/cron.monthly/* \
  && rm -rf /etc/cron.weekly/*

RUN \
  cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -o consul-template_0.16.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.16.0_SHA256SUMS \
  && unzip consul-template_0.16.0_linux_amd64.zip \
  && rm consul-template_0.16.0_linux_amd64.zip consul-template_0.16.0_SHA256SUMS

RUN \
  apt-get remove -y curl unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /usr/local/bin/entrypoint.sh
