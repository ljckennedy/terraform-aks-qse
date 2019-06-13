#!/bin/bash
#set -e
echo "Getting AKS credentials..."
# AKS_NAME="akslkn"; AKS_RG="akslknrg";
az aks get-credentials -n $AKS_NAME -g $AKS_RG --overwrite-existing
echo "######################"
echo "Creating service account and cluster role binding for Tiller..."
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

echo "Initializing Helm..."
helm init --service-account tiller --wait
sleep 30
echo "Helm has been installed."
helm repo update
#azure file storage
kubectl create clusterrole system:azure-cloud-provider --verb=get,create --resource=secrets
kubectl create clusterrolebinding system:azure-cloud-provider --clusterrole=system:azure-cloud-provider --serviceaccount=kube-system:persistent-volume-binder
kubectl apply -f azure-sc.yaml

helm upgrade --install qseonk8s-init edge/qliksense-init 
helm upgrade --install qseonk8s edge/qliksense -f ./basic.yaml
sleep 60
kubectl get service -l app=nginx-ingress --namespace default