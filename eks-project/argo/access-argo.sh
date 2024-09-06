#!/bin/bash

#Get argocd passowrd
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "Login: admin, Password: $ARGOCD_PASSWORD"
kubectl port-forward svc/argocd-server -n argocd 8080:443