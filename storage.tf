resource "azurerm_storage_account" "k8sstorage" {
  name                     = var.cluster_name
  location                 = azurerm_resource_group.aks.location
  resource_group_name      = azurerm_resource_group.aks.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

