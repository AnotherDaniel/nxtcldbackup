#!/bin/sh

env >/etc/environment

# Update Unison profiles with environment variables
# Update SOURCE paths if SOURCE is set
if [ ! -z "$SOURCE" ]; then
    sed -i "s|root  = /mnt/source|root  = $SOURCE|g" /root/.unison/nextcloud_daily.prf
    sed -i "s|force = /mnt/source|force = $SOURCE|g" /root/.unison/nextcloud_daily.prf
    echo "Unison SOURCE path set to $SOURCE"
fi

# Update BACKUP paths if BACKUP is set
if [ ! -z "$BACKUP" ]; then
    # Update daily profile backup paths
    sed -i "s|root = /mnt/backup/daily/|root = $BACKUP/daily/|g" /root/.unison/nextcloud_daily.prf

    # Update weekly profile backup paths
    sed -i "s|root  = /mnt/backup/daily/|root  = $BACKUP/daily/|g" /root/.unison/nextcloud_weekly.prf
    sed -i "s|force = /mnt/backup/daily/|force = $BACKUP/daily/|g" /root/.unison/nextcloud_weekly.prf
    sed -i "s|root = /mnt/backup/weekly/|root = $BACKUP/weekly/|g" /root/.unison/nextcloud_weekly.prf
    echo "Unison BACKUP path set to $BACKUP"
fi

# Ensure log directory exists
mkdir -p /var/log

# execute CMD
echo "$@"
exec "$@"
