provider "helm" {
  kubernetes {
    host                   = var.aks_host_endpoint
    client_certificate     = var.aks_client_certificate
    client_key             = var.aks_client_key
    cluster_ca_certificate = var.aks_cluster_ca_certificate
  }
}

resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  create_namespace = true

  set {
    name  = "podIdentity.azureWorkload.enabled"
    value = "true"
  }

  set {
    name  = "podIdentity.azureWorkload.clientId"
    value = var.keda_umi_client_id
  }

  set {
    name  = "podIdentity.azureWorkload.tenantId"
    value = "7f484261-aa92-4e35-8e51-d881f5d830b5"
  }
}
