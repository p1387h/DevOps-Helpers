# ----- Providers ------------------------------------------

# Configure the Azure Provider.
provider "azurerm" {
  version = "~>2.25.0"
  features {}
}

# Configure the Microsoft Azure Active Directory Provider.
provider "azuread" {
  version = "~>0.11.0"
}

provider "random" {
  version = ">=2.3.0"
}

# ----- Module: AKS ----------------------------------------

module "aks" {
  source = "./aks"

  name                = var.aks_name
  prefix              = "eu"
  suffix              = "01"
  location            = "West Europe"
  aks_version         = "1.17.9"
}