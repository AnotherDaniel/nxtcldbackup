# nxtcldbackup - and more, actually

This is a mini docker image that uses busybox crond to perform daily, weekly and monthly backups from a source to a target directory. It has been created with the intent to backup nextcloud data, where the nextcloud share is mounted via [davfs](https://en.wikipedia.org/wiki/Davfs2). As davfs is not ... blazingly fast, I am using [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to perform the synchronization, as rsync turned out to be too slow to be useful in this context.
However, this is not necessarily limited to backing up nextcloud file shares - should work for every case where you need to take somewhat structured backups/synchronization points of a directory that is available in your file system.

## What it does

When brought up, this container will start crond, which in turn will run daily, weekly and monthly backup scripts.

- the daily script uses [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to synchronize `$SOURCE` to `$BACKUP/daily`, every night
- the weekly script uses [unison](https://www.cis.upenn.edu/~bcpierce/unison/) to synchronize `$BACKUP/daily` to `$BACKUP/weekly`, every week
- the monthly script uses tar to create a compressed archive of `$BACKUP/daily` to `$BACKUP/monthly`
- monthly backups older than 90 days are automatically cleaned up

## Configuration

### Environment Variables

- `SOURCE`: Path to the source directory inside the container (defaults to `/mnt/source`)
- `BACKUP`: Path to the backup directory inside the container (defaults to `/mnt/backup`)
- `UNISONLOCALHOSTNAME`: Hostname for unison configuration (defaults to container name)
- `RETENTION_DAYS`: Number of days to keep monthly backups (defaults to 90)

### Volume Mounts

The container requires three volume mounts:

```yaml
volumes:
  - unison-conf:/root/.unison    # Stores unison configuration and state
  - /mnt/nextcloud:/mnt/source   # Your source data
  - /mnt/nas:/mnt/backup         # Your backup destination
```

## Usage

### Docker Compose

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
      - SOURCE=/mnt/source
      - BACKUP=/mnt/backup
      - RETENTION_DAYS=90    # Optional: defaults to 90 if not set
    volumes:
      - unison-conf:/root/.unison
      - /mnt/nextcloud:/mnt/source
      - /mnt/nas:/mnt/backup
      
volumes:
  unison-conf:
```

## Backup Strategy

The backup system implements a three-tier strategy:

1. **Daily Backups**
   - Run every night
   - Full synchronization of source to daily backup directory
   - Maintains an exact copy of the source

2. **Weekly Backups**
   - Run once per week
   - Synchronizes daily backup to weekly backup directory
   - Provides a weekly snapshot point

3. **Monthly Backups**
   - Run once per month
   - Creates a compressed archive of the daily backup
   - Archives are kept for configurable number of days (default: 90)
   - Older archives are automatically removed

## Logging

Backup operations are logged to `/var/log/backup` inside the container. The log includes:

- Backup start and completion times
- Unison synchronization details
- Cleanup operations
- Error messages (if any)

Logs are automatically rotated weekly, compressed, and kept for 14 days using logrotate.

## Troubleshooting

Common issues and solutions:

1. **Unison Profile Issues**
   - Check that the unison-conf volume is properly mounted
   - Verify SOURCE and BACKUP environment variables
   - Check container logs for profile configuration errors

2. **Permission Issues**
   - Ensure mounted volumes have correct permissions
   - Check that the container has write access to backup locations

3. **Backup Failures**
   - Check container logs
   - Verify source and backup paths are accessible
   - Ensure sufficient disk space in backup location

## ToDos

- If we're bored, might add a configuration switch to use either rsync or unison
- Consider adding backup verification steps
