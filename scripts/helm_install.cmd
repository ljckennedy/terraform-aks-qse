@echo off
echo "Installing helm & kubectl"
SET BASEDIR=echo %cd%
mkdir bin

powershell -noprofile -command "$ProgressPreference = 'SilentlyContinue'; invoke-webrequest https://get.helm.sh/helm-v2.14.1-windows-amd64.zip -outFile $ENV:TEMP\helm-v2.14.1-windows-amd64.zip"
powershell -noprofile -command "expand-archive $ENV:TEMP\helm-v2.14.1-windows-amd64.zip -Destinationpath %cd% -Force"
move /Y  windows-amd64\*.* .\bin\
RD /S /Q windows-amd64
del /F %TEMP%\helm-v2.14.1-windows-amd64.zip
powershell -noprofile -command "$ProgressPreference = 'SilentlyContinue'; invoke-webrequest https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/windows/amd64/kubectl.exe -outFile $ENV:TEMP\kubectl.exe"
move /Y %TEMP%\kubectl.exe .\bin\
SET PATH=.\bin;%PATH%


echo "######################"
echo "Getting AKS credentials..."
:: for testing test variables if not already set..
IF "%AKS_NAME%"=="" ( 
    ECHO Variable is NOT defined
    SET AKS_NAME=akslkn
    SET  AKS_RG=akslknrg
)

echo Cluster details: { NAME: %AKS_NAME%  RG:  %AKS_RG% }
cmd /c az aks get-credentials -n %AKS_NAME%  -g %AKS_RG% --overwrite-existing

echo "######################"
echo "Creating service account and cluster role binding for Tiller..."
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

echo "Initializing Helm..."
helm init --service-account tiller --wait
timeout /t 30 /nobreak > NUL
echo "Helm has been installed."
helm repo add qlik-stable https://qlik.bintray.com/stable
helm repo add qlik-edge https://qlik.bintray.com/edge
helm repo update

::azure file storage
kubectl create clusterrole system:azure-cloud-provider --verb=get,create --resource=secrets
kubectl create clusterrolebinding system:azure-cloud-provider --clusterrole=system:azure-cloud-provider --serviceaccount=kube-system:persistent-volume-binder
kubectl apply -f ./scripts/azure-sc.yaml

helm upgrade --install qseonk8s-init qlik-edge/qliksense-init 
helm upgrade --install qseonk8s qlik-edge/qliksense -f ./scripts/basic.yaml
timeout /t 60 /nobreak > NUL
kubectl get service -l app=nginx-ingress --namespace default
 