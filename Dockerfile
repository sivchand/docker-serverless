ARG NODE_MAJOR=20
ARG PYTHON_VERSION=3.12
FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS build-base

ARG TARGETARCH

RUN yum install -y tar xz unzip || dnf install -y tar xz unzip
ARG JQ_VERSION=1.7.1
ADD --chmod=755 https://github.com/jqlang/jq/releases/download/jq-$JQ_VERSION/jq-linux-$TARGETARCH /usr/local/bin/jq

ARG YQ_VERSION=4.42.1
ADD --chmod=755 https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_$TARGETARCH /usr/local/bin/yq

ARG AWSCLI_VERSION=2.15.23
# Installing awscli
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETARCH" = "arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi && \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}-${AWSCLI_VERSION}.zip" -o "/tmp/awscliv2.zip" \
    && cd /tmp/ && unzip -q awscliv2.zip && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin && aws --version

FROM public.ecr.aws/lambda/nodejs:${NODE_MAJOR} AS nodejs

ARG SLS_VERSION=3.38.0
# Install serverless
RUN npm install --location=global serverless@${SLS_VERSION} && serverless --version

FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS build

COPY --from=nodejs --link /var/lang /var/lang
COPY --from=nodejs --link /usr/local /usr/local
COPY --from=build-base --link /usr/local /usr/local
RUN node --version && npm --version && python3 --version && serverless --version
