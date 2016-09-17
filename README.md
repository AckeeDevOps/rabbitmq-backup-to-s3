# Backup container for rabbitmq instances

This image provides a cron daemon that runs daily backups from rabbitmq to Amazon S3.

Following ENV variables must be specified:
 - `RABBITMQ_ERLANG_COOKIE` contains the secret connection string for rabbitmqctl remote management (both RabbitMQ containers should have the same cookie string set)
 - `RABBITMQ_HOSTNAME` contains the hostname (also referred as "Node name") string for rabbitmqctl remote management (option -n)
 - `S3_URL` contains address in S3 where to store backups
  - `bucket-name/directory`
 - `S3_ACCESS_KEY`
 - `S3_SECRET_KEY`
 - `CRON_SCHEDULE` cron schedule string, default '0 2 * * *'

