provider "azurerm" {
  subscription_id = "3a178ef5-5e43-4941-9f09-558102d7875a"
  features {}
}

resource "azurerm_resource_group" "rg-keda" {
  name     = "keda"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks-keda" {
  name                = "aks-keda-cluster"
  location            = azurerm_resource_group.rg-keda.location
  resource_group_name = azurerm_resource_group.rg-keda.name
  dns_prefix          = "keda"
  oidc_issuer_enabled = true
  workload_identity_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
  }


  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }
}

module "keda" {
  source                     = "./helm-keda"
  aks_host_endpoint          = azurerm_kubernetes_cluster.aks-keda.kube_config[0].host
  aks_client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].client_certificate)
  aks_client_key             = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].client_key)
  aks_cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].cluster_ca_certificate)
}

module "servicebus" {
  source                  = "./servicebus"
  resource_group_location = azurerm_resource_group.rg-keda.location
  resource_group_name     = azurerm_resource_group.rg-keda.name
}
