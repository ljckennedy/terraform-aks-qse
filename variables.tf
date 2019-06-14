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

variable "dns_prefix" {
  default = "tf-aksxyz"
}

variable "cluster_name" {
  default = "tf-aksxyz"
}

variable "resource_group_name" {
  default = "tf-aksxyz-rg"
}

variable "location" {
  default = "westeurope"
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