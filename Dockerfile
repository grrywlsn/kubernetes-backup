FROM alpine:3.20
RUN apk add --update curl coreutils git bash tar gzip && rm -rf /var/cache/apk/*

ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq
ADD https://storage.googleapis.com/kubernetes-release/release/v1.30.1/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

RUN curl -fsSL https://get.helm.sh/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-amd64.tar.gz | tar -xz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
