# FROM ubuntu:22.04 as buildah-build
# 
# RUN apt-get update && apt-get -y install software-properties-common && \
#   add-apt-repository -y ppa:alexlarsson/flatpak && \
#   add-apt-repository -y ppa:gophers/archive && \
#   apt-add-repository -y ppa:projectatomic/ppa && \
#   apt-get -y -qq update && \
#   apt-get -y install bats btrfs-tools git libapparmor-dev libdevmapper-dev libglib2.0-dev libgpgme11-dev libseccomp-dev libselinux1-dev skopeo-containers go-md2man &&\
#   apt-get -y install golang-1.13
# RUN mkdir ~/buildah && \
#   cd ~/buildahi && \
#   export GOPATH=`pwd` && \
#   git clone https://github.com/containers/buildah ./src/github.com/containers/buildah && \
#   cd ./src/github.com/containers/buildah && \
#   PATH=/usr/lib/go-1.13/bin:$PATH make runc all SECURITYTAGS="apparmor seccomp" && \
#   sudo make install install.runci && \
#   buildah --help

FROM sivchand/pyenv

ARG TARGETARCH

RUN pyenv local 3.8.13 && \
    python -m pip install -U pip && \
    pyenv local --unset && \
    pyenv rehash

ARG YQ_VERSION=4.24.5
RUN curl -sL https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_$TARGETARCH -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

ARG NODE_VERSION=16.15.1
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCH=x64; elif [ "$TARGETARCH" = "arm64" ]; then ARCH=aarch64; else ARCHITECTURE=x64; fi && \
    echo "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" && \
    curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" && \
    tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner   && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    node --version && \
    npm --version

ARG SLS_VERSION=3.17.0
# Install serverless
RUN npm install --location=global serverless@${SLS_VERSION}

RUN apt-get update && \
    apt-get install -y unzip jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ARG AWSCLI_VERSION=2.6.3
# Installing awscli
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETARCH" = "arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi && \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}-${AWSCLI_VERSION}.zip" -o "/tmp/awscliv2.zip" \
    && cd /tmp/ && unzip -q awscliv2.zip && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
