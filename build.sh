#!/bin/sh

NODE_VERSION=16.19.0
SLS_VERSION=3.38.0
AWSCLI_VERSION=2.15.23
YQ_VERSION=4.42.1
JQ_VERSION=1.7.1

for PYTHON_VERSION in $(cat python-versions.txt)
do
docker buildx build --platform=linux/amd64,linux/arm64 --push -t sivchand/serverless:$SLS_VERSION-python-$PYTHON_VERSION-awscli-$AWSCLI_VERSION-node-$NODE_VERSION --build-arg NODE_VERSION=$NODE_VERSION --build-arg SLS_VERSION=$SLS_VERSION --build-arg AWSCLI_VERSION=$AWSCLI_VERSION --build-arg FROM_IMAGE=public.ecr.aws/lambda/python:$PYTHON_VERSION .
done
