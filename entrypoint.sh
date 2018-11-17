#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo "$CONTAINER_TIMEZONE" > /etc/timezone \
    && ln -sf "/usr/share/zoneinfo/$CONTAINER_TIMEZONE" /etc/localtime
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

mkdir -p $BACKUP_PATH

printenv | sed 's/^\(.*\)$/export \1/g' > /root/env

delay=""
if [ -n "$BACKUP_IS_RANDOM_DELAY" ]; then
  delay="sleep ${RANDOM:0:2}m ;"
fi

( crontab -l ; echo "$BACKUP_MINUTE $BACKUP_HOUR * * * $delay . /root/env ; /usr/local/bin/backup.sh >/proc/1/fd/1 2>/proc/1/fd/2" ) | crontab -

crond -f &
child=$!

trap "kill $child" INT TERM
wait "$child"
trap - INT TERM
wait "$child"
