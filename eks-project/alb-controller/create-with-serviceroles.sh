#!/bin/bash

#https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
EKS_CLUSTER_NAME=$1

if [ -z "$EKS_CLUSTER_NAME" ]; then
    echo "Usage: $0 <EKS_CLUSTER_NAME>"
    exit 1
fi

#Script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://alb-cotroller-policy.json

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

eksctl create iamserviceaccount \
    --cluster=$EKS_CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$EKS_CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller