#!/bin/bash
echo "installing helm & kubectl"
mkdir ./bin
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
mv kubectl ./bin/
curl -LO  https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
tar xvfz helm-v2.14.1-linux-amd64.tar.gz
mv linux-amd64/* ./bin/
rmdir linux-amd64
rm helm-v2.14.1-linux-amd64.tar.gz
export PATH=./bin;$PATH

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
# echo 'adding qlik helm repo'
helm repo add qlik-stable https://qlik.bintray.com/stable
helm repo add qlik-edge https://qlik.bintray.com/edge
helm repo update


#azure file storage
kubectl create clusterrole system:azure-cloud-provider --verb=get,create --resource=secrets
kubectl create clusterrolebinding system:azure-cloud-provider --clusterrole=system:azure-cloud-provider --serviceaccount=kube-system:persistent-volume-binder
kubectl apply -f ./scripts/azure-sc.yaml

helm upgrade --install qseonk8s-init qlik-edge/qliksense-init 
helm upgrade --install qseonk8s eqlik-edgedge/qliksense -f ./scripts/basic.yaml
sleep 60
kubectl get service -l app=nginx-ingress --namespace default
