provider "azurerm" {
  version = "~> 1.30"
  subscription_id = var.subscription_id
}

provider "azuread" {
  version = "~> 0.4"
}

