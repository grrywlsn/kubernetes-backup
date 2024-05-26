FROM alpine:3.20
RUN apk add --update curl coreutils git  && rm -rf /var/cache/apk/*
ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]