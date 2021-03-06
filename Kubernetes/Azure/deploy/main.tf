# ----- Providers ------------------------------------------

# Configure the Azure Provider.
provider "azurerm" {
  features {}
}

# Configure the Microsoft Azure Active Directory Provider.
provider "azuread" {
}

provider "random" {
}

# ----- Module: Shared resources ---------------------------

module "shared" {
  source = "./shared"

  name     = var.shared_name
  prefix   = "eu"
  suffix   = "00"
  location = "West Europe"
}

# ----- Module: AKS ----------------------------------------

module "aks" {
  source = "./aks"

  name              = var.aks_name
  prefix            = "eu"
  suffix            = "01"
  location          = "West Europe"
  aks_version       = null # Use the default one provided by Azure.
  acr_id            = module.shared.acr_id
  current_public_ip = var.current_public_ip
}