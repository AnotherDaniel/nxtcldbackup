FROM alpine:latest

RUN apk add --update tini unison logrotate && rm -rf /var/cache/apk/*

# Copy scripts to /usr/local/lib
COPY scripts/* /usr/local/lib/
RUN chmod +x /usr/local/lib/*

COPY periodic /etc/periodic
RUN chmod -R +x /etc/periodic

COPY config/backup /etc/logrotate.d/backup

# This directory holds unison config profiles, but also the unison sync
# reports/datasets. To have this work properly (profiles should be there,
# but also the sync reports should be persistet across container restarts),
# this directory should be done as a volume-mount when running the container.
# ATTENTION: to make a rebuild pick up changes here, remove this volume manually!
#   docker volume rm nxtcldbackup_unison-conf
RUN mkdir /root/.unison
COPY unison/* /root/.unison/

ENTRYPOINT [ "tini", "-s", "-g", "--", "/usr/local/lib/entrypoint.sh" ]

# -f | Foreground
CMD ["crond", "-f", "-d", "8", "-c", "/etc/crontabs"]
