ARG FROM_IMAGE=public.ecr.aws/lambda/python:3.9
FROM $FROM_IMAGE AS build-base

ARG TARGETARCH

RUN yum install -y tar xz unzip || dnf install -y tar xz unzip
ARG JQ_VERSION=1.7.1
ADD --chmod=755 https://github.com/jqlang/jq/releases/download/jq-$JQ_VERSION/jq-linux-$TARGETARCH /usr/local/bin/jq

ARG YQ_VERSION=4.42.1
ADD --chmod=755 https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_$TARGETARCH /usr/local/bin/yq

ARG NODE_VERSION=16.19.0
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCH=x64; elif [ "$TARGETARCH" = "arm64" ]; then ARCH=arm64; else ARCHITECTURE=x64; fi && \
    curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" && \
    tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner   && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    node --version && \
    npm --version

ARG SLS_VERSION=3.38.0
# Install serverless
RUN npm install --location=global serverless@${SLS_VERSION}

ARG AWSCLI_VERSION=2.15.23
# Installing awscli
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETARCH" = "arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi && \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}-${AWSCLI_VERSION}.zip" -o "/tmp/awscliv2.zip" \
    && cd /tmp/ && unzip -q awscliv2.zip && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin && aws --version

FROM $FROM_IMAGE as build

COPY --from=build-base --link /usr/local /usr/local
