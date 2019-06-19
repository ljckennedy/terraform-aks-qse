data "azuread_service_principal" "akssp" {
  application_id = var.client_id
}

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.mylocation
  count = "${length(var.myrg) > 1 ? 0 : 1}"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = "${length(var.mylocation) > 1 ? var.mylocation : azurerm_resource_group.aks[0].location }"
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  address_space       = ["10.1.0.0/16"]
  count = "${length(var.myrg) > 1 ? 0 : 1}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "aksnodes"
  resource_group_name  = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.vnet[0].name}"
  count = "${length(var.myrg) > 1 ? 0 : 1}"
}


resource "azurerm_kubernetes_cluster" "aksqse" {
  name                = var.cluster_name
  location            = "${length(var.mylocation) > 1 ? var.mylocation : azurerm_resource_group.aks[0].location }"
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  agent_pool_profile {
    name            = "agentpool"
    count           = var.agent_count
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id = "${length(var.myrg) > 1 ? var.mysubnet : azurerm_subnet.subnet[0].id }" 
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  # network_profile {
  #   network_plugin = "${var.network_plugin}"
  # }

  role_based_access_control {
    enabled = true
  }

  tags = {
    Environment = "Development"
  }
  #   provisioner "local-exec" {
  #     command =  "${var.client_type == "linux" ? var.linux_script : var.windows_script}"
  #     environment = {
  #       AKS_NAME = "${var.cluster_name}"
  #       AKS_RG   = "${var.resource_group_name}"
  #     }
  #   }
}



# resource "azurerm_role_assignment" "netcontribrole" {
#   scope                = "${azurerm_subnet.subnet.id}"
#   role_definition_name = "Network Contributor"
#   principal_id         = "${data.azuread_service_principal.akssp.object_id}"
# }

