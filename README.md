# nxtcldbackup - and more, actually

This is a mini docker image that uses busybox crond to perform daily, weekly and monthly backups from a webdav mount to a target directory. It has been created with the intent to backup nextcloud data, where the nextcloud share is mounted via [davfs](https://en.wikipedia.org/wiki/Davfs2). As davfs is not ... blazingly fast, I am using [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to perform the synchronization, as rsync turned out to be too slow to be useful in this context.

## What it does

When brought up, this container will start crond, which in turn will run daily, weekly and monthly backup scripts.

- the daily script uses [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to synchronize the webdav mount to `$BACKUP/daily`, every night
- the weekly script uses [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to synchronize `$BACKUP>/daily` to `$BACKUP>/weekly`, every week
- the monthly script uses tar to create a compressed archive of `$BACKUP>/daily` to `$BACKUP>/monthly`

## Usage

The `$BACKUP` directories are declared via volume mounts when starting the docker container - e.g. like this when using docker compose:

```yaml
services:
  nxtcldbackup:
    container_name: nxtcldbackup
    build:
      context: .
      dockerfile: Dockerfile
    init: true
    environment:
      - UNISONLOCALHOSTNAME=nxtcldbackup
      - BACKUP=/mnt/backup
      - WEBDRIVE_USERNAME=
      - WEBDRIVE_PASSWORD=
      - WEBDRIVE_URL=
      - DAVFS2_ASK_AUTH=0
      - DAVFS2_USE_LOCKS=0
    devices:
      - /dev/fuse
    cap_add:
      - SYS_ADMIN
    volumes:
      - unison-conf:/root/.unison
      - /mnt/backup:/mnt/backup

volumes:
  unison-conf:

```

## ToDos

- once this has proved to work reasonably well, add logic to remove monthly backups older than a certain (configurable) time period
- if we're bored, might add a configuration switch to use either rsync or unison
