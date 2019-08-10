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

variable "vm_size" {
  default = "Standard_DS2_v2"
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

variable "network_plugin" {
  description = "If Set, set to azure or kubenet"
  default = "kubenet"
}

variable "service_cidr" {
  description = " The Network Range used by the Kubernetes service. This is required when network_plugin is set to azure"
  default = null
}

variable "dns_service_ip" {
  description = " IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
  default = null
}

variable "docker_bridge_cidr" {
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. This is required when network_plugin is set to azure"
  default = null
}

variable "max_pods" {
  description = "number of pods allowed per node"
  default = 30
}
