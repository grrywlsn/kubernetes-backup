FROM alpine:3.19.1
RUN apk add --update curl coreutils git  && rm -rf /var/cache/apk/*
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]