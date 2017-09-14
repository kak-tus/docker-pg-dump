#!/usr/bin/env sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

consul-template -once -template "/root/pgpass.template:/root/.pgpass"

chmod 0600 /root/.pgpass

dbs=$( psql -h $BACKUP_HOST -U postgres -c 'COPY ( SELECT datname FROM pg_database WHERE datistemplate = false ) TO STDOUT;' )

dt=`date +%Y-%m-%d_%H:%M:%S`

for db in $dbs; do
  echo "Backup $db"
  pg_dump -h $BACKUP_HOST -U postgres $db > $BACKUP_PATH/${db}_$dt.sql
  bzip2 $BACKUP_PATH/${db}_$dt.sql
done
