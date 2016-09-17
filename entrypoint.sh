#!/bin/bash
set -eo pipefail

# verify variables
if [ -z "$S3_ACCESS_KEY" -o -z "$S3_SECRET_KEY" -o -z "$S3_URL" -o -z "$RABBITMQ_ERLANG_COOKIE" -o -z "$RABBITMQ_HOSTNAME" ]; then
	echo >&2 'Backup information is not complete. You need to specify S3_ACCESS_KEY, S3_SECRET_KEY, S3_URL, RABBITMQ_HOSTNAME, RABBITMQ_ERLANG_COOKIE. No backups, no fun.'
	exit 1
fi
echo $RABBITMQ_ERLANG_COOKIE >> /var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie
CFG_FILE=/root/.s3cfg

# set s3 config
sed -i "s/%%S3_ACCESS_KEY%%/$S3_ACCESS_KEY/g" $CFG_FILE
sed -i "s/%%S3_SECRET_KEY%%/$S3_SECRET_KEY/g" $CFG_FILE

# verify S3 config
s3cmd -c $CFG_FILE ls "s3://$S3_URL" > /dev/null

# set cron schedule TODO: check if the string is valid (five or six values separated by white space)
[[ -z "$CRON_SCHEDULE" ]] && CRON_SCHEDULE='0 2 * * *' && \
   echo "CRON_SCHEDULE set to default ('$CRON_SCHEDULE')"

REMOTE=rabbit@$RABBITMQ_HOSTNAME
echo "Verifying RABBITMQ_ERLANG_COOKIE..."
rabbitmqctl -n $REMOTE list_users >/dev/null
echo "Success."

# add a cron job
echo "$CRON_SCHEDULE root rm -rf /tmp/all.tgz &&\
  rabbitmqctl -n $REMOTE stop_app &&\
  tar czf /tmp/all.tgz /var/lib/rabbitmq/ &&\
  rabbitmqctl -n $REMOTE start_app &&\
  s3cmd -c $CFG_FILE sync /tmp/ s3://$S3_URL/ &&\
  rm -rf /tmp/all.tgz" >> /etc/crontab
crontab /etc/crontab

exec "$@"
