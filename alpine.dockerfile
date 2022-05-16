FROM alpine:latest

RUN apk add --update rsync unison && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY periodic /etc/periodic
RUN chmod -R +x /etc/periodic

# This directory holds unison config profiles, but also the unison sync
# reports/datasets. To have this work properly (profiles should be there,
# but also the sync reports should be persistet across container restarts),
# this directory should be done as a volume-mount when running the container.
RUN mkdir /root/.unison
COPY unison/*.prf /root/.unison/

ENTRYPOINT ["/entrypoint.sh"]

# -f | Foreground
CMD ["crond", "-f", "-d", "8", "-c", "/etc/crontabs"]
