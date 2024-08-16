#!/bin/bash
APP_NAME=$1
TAG=$2
REPO_CREATE=$3

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name> [tag] [create]"
    exit 1
fi
if [ -z "$TAG" ]; then
    TAG="latest"
fi
if [ -z "$REPO_CREATE" ]; then
    # Dereive registry id
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account | tr -d '"')
    REPO_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME"    
else
    REPO_URI=$(aws ecr create-repository --repository-name $APP_NAME | jq -r '.repository.repositoryUri')
fi

docker build --platform linux/amd64 -t $REPO_URI:latest -f docker/Dockerfile ./src
docker push $REPO_URI:latest