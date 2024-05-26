FROM alpine:3.20
RUN apk add --update curl coreutils git  && rm -rf /var/cache/apk/*
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]