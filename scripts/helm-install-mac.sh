#!/bin/bash
echo "installing helm & kubectl"
mkdir ./bin
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
mv kubectl ./bin/
chmod +x ./bin/kubectl 
curl -LO  https://get.helm.sh/helm-v2.14.1-darwin-amd64.tar.gz
tar xvfz helm-v2.14.1-darwin-amd64.tar.gz
mv darwin-amd64/* ./bin/
rmdir -fr darwin-amd64
rm helm-v2.14.1-darwin-amd64.tar.gz
export PATH="./bin:"

echo "Getting AKS credentials..."
#AKS_NAME="qse4qmi"; AKS_RG="Pre-Sales-aor";AKS_SUBSCRIPTION="e2f7b1c0-b282-4d73-b95f-8ebc778040b8";
az aks get-credentials -n $AKS_NAME -g $AKS_RG --subscription $AKS_SUBSCRIPTION --overwrite-existing
echo "######################"
#echo "Creating service account and cluster role binding for Tiller..."
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

echo "Initializing Helm..."
helm init --upgrade --service-account tiller --wait
sleep 30
echo "Helm has been installed."
sleep 10
echo 'Adding qlik helm repo'
helm repo add qlik-stable https://qlik.bintray.com/stable
helm repo add qlik-edge https://qlik.bintray.com/edge
helm repo update

#azure file storage
echo "Configure StorageClass 'azurefile'."
kubectl create clusterrole system:azure-cloud-provider --verb=get,create --resource=secrets
kubectl create clusterrolebinding system:azure-cloud-provider --clusterrole=system:azure-cloud-provider --serviceaccount=kube-system:persistent-volume-binder
kubectl apply -f ./scripts/azure-sc.yaml

echo "Deploying Qlik Sense Enterprise on Kubernetes."
helm upgrade --install qseonk8s-init qlik-stable/qliksense-init 
helm upgrade --install qseonk8s qlik-stable/qliksense -f ./scripts/basic-sample.yaml
sleep 20
#kubectl get service -l app=nginx-ingress --namespace default

kubectl get pod -o wide
echo "Monitor QSE status deployment by executing: "
echo "  ==> kubectl get pod -o wide -w"
