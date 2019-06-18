resource "azurerm_storage_account" "k8sstorage" {
  name                     = var.cluster_name
  location                 =  "${length(var.mylocation) > 1 ? var.mylocation : azurerm_resource_group.aks[0].location }"
  resource_group_name      = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

