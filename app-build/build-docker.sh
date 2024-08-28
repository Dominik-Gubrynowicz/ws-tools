#!/bin/bash
APP_NAME=$1
TAG=$2

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name> [tag]"
    exit 1
fi
if [ -z "$AWS_REGION" ]; then
    echo "AWS_REGION environment variable is not set"
    exit 1
fi
if [ -z "$TAG" ]; then
    TAG="latest"
fi



# Dereive registry id
ACCOUNT_ID=$(aws sts get-caller-identity --query Account | tr -d '"')
REPO_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME"

docker build --platform linux/amd64 -t $REPO_URI:${TAG} -f docker/Dockerfile ..
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
docker push $REPO_URI:${TAG}