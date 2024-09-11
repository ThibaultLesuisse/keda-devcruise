provider "azurerm" {
  subscription_id = "3a178ef5-5e43-4941-9f09-558102d7875a"
  features {}
}

resource "azurerm_resource_group" "rg-keda" {
  name     = "keda"
  location = "West Europe"
}

locals {
  tenant_id = "7f484261-aa92-4e35-8e51-d881f5d830b5"
}

resource "azurerm_kubernetes_cluster" "aks-keda" {
  name                      = "aks-keda-cluster"
  location                  = azurerm_resource_group.rg-keda.location
  resource_group_name       = azurerm_resource_group.rg-keda.name
  dns_prefix                = "keda"
  oidc_issuer_enabled       = true
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

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks-keda.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-keda.kube_config[0].cluster_ca_certificate)
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


resource "azurerm_user_assigned_identity" "umi_application" {
  location            = azurerm_resource_group.rg-keda.location
  resource_group_name = azurerm_resource_group.rg-keda.name
  name                = "umi-webapplication"
}

resource "azurerm_federated_identity_credential" "umi_application_federated_credentials" {
  name                = azurerm_user_assigned_identity.umi_application.name
  resource_group_name = azurerm_user_assigned_identity.umi_application.resource_group_name
  parent_id           = azurerm_user_assigned_identity.umi_application.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks-keda.oidc_issuer_url
  subject             = "system:serviceaccount:default:devcruise-deployment"
}

resource "azurerm_user_assigned_identity" "umi_function" {
  location            = azurerm_resource_group.rg-keda.location
  resource_group_name = azurerm_resource_group.rg-keda.name
  name                = "umi-function"
}

resource "azurerm_federated_identity_credential" "umi_function_federated_credentials" {
  name                = azurerm_user_assigned_identity.umi_function.name
  resource_group_name = azurerm_user_assigned_identity.umi_function.resource_group_name
  parent_id           = azurerm_user_assigned_identity.umi_function.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks-keda.oidc_issuer_url
  subject             = "system:serviceaccount:default:function"
}

resource "azurerm_role_assignment" "umi_application_role_assignment" {
  scope                = module.servicebus.queue.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.umi_application.principal_id
}

resource "azurerm_role_assignment" "umi_function_role_assignment" {
  scope                = module.servicebus.queue.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.umi_function.principal_id
}

resource "local_file" "all_metrics_sql" {
  filename = "../kubernetes/kustomize/patch-serviceaccount.yaml"
  content = templatefile("${path.module}/patch-serviceaccount.tftpl", {
    client_id = azurerm_user_assigned_identity.umi_application.client_id
  })
}

resource "kubernetes_deployment_v1" "application_deployment" {
  metadata {
    name = "devcruise-deployment"
    labels = {
      app = "devcruise-app"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "devcruise-app"
      }
    }
    template {
      metadata {
        annotations = {
          "azure.workload.identity/use" = "true"
        }
        labels = {
          app = "devcruise-app"
        }
      }
      spec {
        container {
          name  = "api"
          image = "thibaultlesuisse/valentinephilippe:latest"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "application_service" {
  metadata {
    name = "application-service"
    labels = {
      app = "apllication-service-app"
    }
  }
  spec {
    port {
      port        = 80
      target_port = 8080
    }
    selector = {
      app = "devcruise-app"
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_service_account_v1" "application_service_account" {
  metadata {
    name = "application-service-account"
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.umi_application.client_id
      "azure.workload.identity/tenant-id" = local.tenant_id
    }
  }
}
