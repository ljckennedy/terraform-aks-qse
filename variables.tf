variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "agent_count" {
  default = 1
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "cluster_name" {
  default = "tf-aksxyz"
}

variable "resource_group_name" {
  default = "tf-aksxyz-rg"
}

variable "presales_subnet_id" {
    default = "/subscriptions/e2f7b1c0-b282-4d73-b95f-8ebc778040b8/resourceGroups/IT-Infra-Mgmt/providers/Microsoft.Network/virtualNetworks/IT-Infra-Mgmt-VNet/subnets/Pre-Sales-Subnet"
}

variable "location" {
  default = "eastus"
}

variable "network_plugin" {
  default = "kubenet"
}

variable "kubernetes_version" {
  default = "1.13.8"
}

variable "linux_script" {
  default = "./scripts/helm-install.sh"
}
variable "windows_script" {
  default = ".\\scripts\\helm_install.cmd"
}

variable "client_type" {
}