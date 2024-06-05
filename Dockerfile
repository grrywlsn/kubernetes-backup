FROM alpine:3.20
RUN apk add --update curl coreutils git bash && rm -rf /var/cache/apk/*
ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq
ADD https://storage.googleapis.com/kubernetes-release/release/v1.30.1/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
