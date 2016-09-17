# Backup container for rabbitmq instances

This image provides a cron daemon that runs daily backups from rabbitmq to Amazon S3.

Following ENV variables must be specified:
 - `MONGO_URL` contains the connection string for mongodump command line client (option -h)
 - `MONGO_USER` contains the username
 - `MONGO_PASSWORD` password of a user who has access to all dbs
 - `S3_URL` contains address in S3 where to store backups
  - `bucket-name/directory`
 - `S3_ACCESS_KEY`
 - `S3_SECRET_KEY`
 - `CRON_SCHEDULE` cron schedule string, default '0 2 * * *'

