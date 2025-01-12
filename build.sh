#!/bin/sh

SLS_VERSION=3.40.0
AWSCLI_VERSION=2.22.33
YQ_VERSION=4.45.1
JQ_VERSION=1.7.1

for NODE_VERSION in $(cat node-versions.txt)
do
for PYTHON_VERSION in $(cat python-versions.txt)
do
docker buildx build --platform=linux/amd64,linux/arm64 --push \
	-t sivchand/serverless:${SLS_VERSION%.*}-python-$PYTHON_VERSION-awscli-${AWSCLI_VERSION%.*}-node-${NODE_VERSION%%.*} \
	--build-arg NODE_MAJOR=${NODE_VERSION%%.*} \
	--build-arg SLS_VERSION=$SLS_VERSION \
	--build-arg AWSCLI_VERSION=$AWSCLI_VERSION \
	--build-arg PYTHON_VERSION=${PYTHON_VERSION} \
	.
done
done
