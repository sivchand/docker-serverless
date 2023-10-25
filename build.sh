#!/bin/sh

PYTHON_VERSION=3.11
NODE_VERSION=16.19.0
SLS_VERSION=3.35.2
AWSCLI_VERSION=2.13.26
YQ_VERSION=4.30.4

docker buildx build --platform=linux/amd64,linux/arm64 --push -t sivchand/serverless:$SLS_VERSION-python-$PYTHON_VERSION-awscli-$AWSCLI_VERSION-node-$NODE_VERSION --build-arg NODE_VERSION=$NODE_VERSION --build-arg SLS_VERSION=$SLS_VERSION --build-arg AWSCLI_VERSION=$AWSCLI_VERSION --build-arg FROM_IMAGE=public.ecr.aws/lambda/python:$PYTHON_VERSION .
