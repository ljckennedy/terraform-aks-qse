# terraform-aks-qse
Terraform scripts for deploying QSE on Kubernetes on Azure (Presales)

---
## What you need:
Create a Service Principal if you still don't have one:
```Bash
az ad sp create-for-rbac --subscription <presales_subscription_id>

A response like this will return
{
  "appId": "bbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "displayName": "azure-cli-2019-06-11-10-25-44",
  "name": "http://azure-cli-2019-06-11-10-25-44",
  "password": "shhhhhhhhhhhhhhhhhhhhhhh",
  "tenant": "aaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
```

a variables file i.e. __qse.tfvars__ containing:
```Bash
#these comes from your azure tenant
client_id = "bbbbbbbbbbbbbbbbbbbbbbbbbbbb"
client_secret = "shhhhhhhhhhhhhhhhhhhhhhh"
subscription_id = "<presales_subscription_id>"
resource_group_name="Pre-Sales-<trigram>" #Predefined RG in Qlik Presales Azure subscription
presales_subnet_id="/subscriptions/<presales_subscription_id>/resourceGroups/IT-Infra-Mgmt/providers/Microsoft.Network/virtualNetworks/IT-Infra-Mgmt-VNet/subnets/Pre-Sales-Subnet"

#these are up to you.
client_type="linux"
cluster_name = "xxxxxx"
location="East US"
```

ssh keys set up.  It is expecting to find *~/.ssh/id_rsa.pub* & *~/.ssh/id_rsa*

## How to:
```Bash
cd /somedirectory
git clone https://github.com/mjromper/terraform-aks-qse.git
cp myvarsfileicreated.tfvars ./terraform-aks-qse/qse.tfvars
cd ./terraform-aks-qse
terraform init
terraform apply -var-file=qse.tfvars
```
All going well this should run for about 10-15 minutes and then QSE pods start creating. Monitor QSE deployment status with 
```Bash
kubectl get pod -o wide -w
```
You need to add to your Hosts file an entry to resolve the Private IP given to your K8s cluster.

```Bash
<cluster_private_ip> elastic.example
```
Then access the Qlik Sense Hub on https://elastic.example:32443
Or the Console on https://elastic.example:32443/console

---
## Notes
This has been developed and tested from the client side on ubuntu using WSL in windows 10.  Any linux/unix environment should work, but others have not been tested.

This has been built for **_demo purposes only_**.  It should not be seen as secure, production grade nor best practice.  This was primarily done as a learning exercise for myself.  


Thanks to Clint Carr's https://github.com/clintcarr/qlik-sense-azure-terraform which I used as a template and was a huge help!