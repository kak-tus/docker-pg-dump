#!/usr/bin/env sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

consul-template -once -template "/root/pgpass.template:/root/.pgpass" \
  -template "/root/rsyncd_password_file.template:/root/.rsyncd_password_file"

chmod 0600 /root/.pgpass
chmod 0600 /root/.rsyncd_password_file

dbs=$( psql -h $BACKUP_HOST -U postgres -c 'COPY (SELECT datname FROM pg_database WHERE datistemplate = false) TO STDOUT;' )

dt=`date +%Y-%m-%d_%H:%M:%S`

for db in $dbs; do
  echo "Backup $db"
  pg_dump -h $BACKUP_HOST -U postgres $db > /root/${db}_$dt.sql
  bzip2 /root/${db}_$dt.sql
  rsync --password-file=/root/.rsyncd_password_file /root/${db}_$dt.sql.bz2 backup@backup.prepodam.ru::backup/postgresql/
  rm /root/${db}_$dt.sql.bz2
done
