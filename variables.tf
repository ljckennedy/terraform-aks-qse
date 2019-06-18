variable "client_id" {
}

variable "client_secret" {
}

variable "subscription_id" {
}

variable "tenant_id" {
}

variable "agent_count" {
  default = 1
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "tf-aksxyz"
}

variable "cluster_name" {
  default = "tf-aksxyz"
}

variable "resource_group_name" {
  default = "tf-aksxyz-rg"
}

// variable "location" {
//   default = "westeurope"
// }

variable "network_plugin" {
  default = "kubenet"
}

variable "kubernetes_version" {
  default = "1.13.5"
}

variable "linux_script" {
  default = "./scripts/helm-install.sh"
}

variable "windows_script" {
  default = ".\\scripts\\helm_install.cmd"
}

variable "client_type" {
}

variable "newrg" {
    description = "set to 1 to create a new resource group, 0 uses variable myrg"
    default = 0
}

variable "myrg" {
  description = "If set, this resource group will be used, otherwise a new oen is create."
  default = ""
}

variable "mysubnet" {
  description = "If Set, this subnet will be used, otherwise one is created"
  default = null
}

variable "mylocation" {
  description = "If Set, this subnet will be used, otherwise one is created"
  default = null
}

// variable "mylocation" {
//   description = "If Set, this subnet will be used, otherwise one is created"
//   default = null
// }
