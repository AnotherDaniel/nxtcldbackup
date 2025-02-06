FROM alpine:latest

# Specify URL, username and password to communicate with the remote webdav
# resource. When using _FILE, the password will be read from that file itself,
# which helps passing further passwords using Docker secrets.
ENV WEBDRIVE_URL=
ENV WEBDRIVE_USERNAME=
ENV WEBDRIVE_PASSWORD=
ENV WEBDRIVE_PASSWORD_FILE=

# User ID of share owner
ENV OWNER=0

# Location of directory where to mount the drive into the container.
ENV WEBDRIVE_MOUNT=/mnt/webdrive

# In addition, all variables that start with DAVFS2_ will be converted into
# davfs2 compatible options for that share, once the leading DAVFS2_ have been
# removed and once converted to lower case. So, for example, specifying
# DAVFS2_ASK_AUTH=0 will set the davfs2 configuration option ask_auth to 0 for
# that share. See the manual for the list of available options.

RUN apk --no-cache add ca-certificates davfs2 rsync tini unison && rm -rf /var/cache/apk/*

COPY *.sh /usr/local/bin/

# This directory holds unison config profiles, abut also the unison sync
# reports/datasets. To have this work properly (profiles should be there,
# but also the sync reports should be persistet across container restarts),
# this directory should be done as a volume-mount when running the container.
# ATTENTION: to make a rebuild pick up changes here, remove this volume manually!
#   docker volume rm nxtcldbackup_unison-conf
RUN mkdir /root/.unison
COPY unison/* /root/.unison/

COPY periodic /etc/periodic
RUN chmod -R +x /etc/periodic

# Following should match the WEBDRIVE_MOUNT environment variable.
VOLUME [ "/mnt/webdrive" ]

# The default is to perform all system-level mounting as part of the entrypoint
# to then have a command that will keep listing the files under the main share.
# Listing the files will keep the share active and avoid that the remote server
# closes the connection.
ENTRYPOINT [ "tini", "-s", "-g", "--", "/usr/local/bin/entrypoint.sh" ]
#CMD [ "ls.sh" ]
CMD ["crond", "-f", "-d", "8", "-c", "/etc/crontabs"]
