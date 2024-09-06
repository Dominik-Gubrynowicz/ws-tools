# Login to eks cluster
EKS_CLUSTER_NAME=$1

if [ -z "$EKS_CLUSTER_NAME" ]; then
    echo "EKS cluster name is required"
    exit 1
fi

aws eks update-kubeconfig --name $EKS_CLUSTER_NAME