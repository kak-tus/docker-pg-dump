#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo ${CONTAINER_TIMEZONE} >/etc/timezone \
    && ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

mkdir -p $BACKUP_PATH

printenv | sed 's/^\(.*\)$/export \1/g' > /root/env

( crontab -l ; echo '0 0 * * * . /root/env ; /usr/local/bin/backup.sh >/proc/1/fd/1 2>/proc/1/fd/2' ) | crontab

cron -f >/proc/1/fd/1 2>/proc/1/fd/2 &
child=$!

trap "kill $child" TERM
wait "$child"
