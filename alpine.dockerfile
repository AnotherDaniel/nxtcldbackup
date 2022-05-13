FROM alpine:latest

RUN apk add --update rsync unison && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY periodic /etc/periodic
RUN chmod -R +x /etc/periodic

RUN mkdir /root/.unison
COPY unison/*.prf /root/.unison/

ENTRYPOINT ["/entrypoint.sh"]

# -f | Foreground
CMD ["crond", "-f", "-d", "8", "-c", "/etc/crontabs"]
