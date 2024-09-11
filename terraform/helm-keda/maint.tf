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
}
