# ----- Setup ----------------------------------------------

# Create the resource group.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# ----- Networking - Internal-------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-network"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.1.0.0/16"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_route_table" "route_table" {
  name                = "${var.name}-routetable"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet_route_table_association" "subnet_to_route_table" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

# ----- Networking - External-------------------------------

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-ip"
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = lower("${var.name}ip${var.unique_ending}")

  # Create the ip inside the cluster resource group to ensure that the load 
  # balancer can access it.
  depends_on          = [azurerm_kubernetes_cluster.cluster]
  resource_group_name = local.node_resource_group_name
}

# ----- AKS ------------------------------------------------

locals {
  node_resource_group_name = "${azurerm_resource_group.resource_group.name}-Resources"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  node_resource_group = local.node_resource_group_name
  dns_prefix          = lower("${var.name}-aks")
  kubernetes_version  = "1.15.10"

  default_node_pool {
    name            = "default"
    vm_size         = "Standard_B2ms"
    max_pods        = 30
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"

    # Required for advanced networking.
    vnet_subnet_id = azurerm_subnet.subnet.id

    # Required for autoscaling.
    enable_auto_scaling = true
    node_count          = 1
    min_count           = 1
    max_count           = 3
    availability_zones  = [1,2,3] # Requires "Standard" load balancer.
  }

  # Make use of an azure managed identy.
  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }

    # Monitoring.
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "Standard" # Needed for availability zones.
  }

  role_based_access_control {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to the node count since it is managed by the auto scaler.
      default_node_pool[0].node_count
    ]
  }
}

# ----- Registry -------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                     = lower("${var.name}acr${var.unique_ending}")
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  sku                      = "Basic"
}

resource "azurerm_role_assignment" "cluster_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}

# ----- Monitoring -----------------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.name}-law"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}