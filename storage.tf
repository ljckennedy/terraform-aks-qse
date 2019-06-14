resource "azurerm_storage_account" "k8sstorage" {
  name                = "${var.cluster_name}storage"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

}