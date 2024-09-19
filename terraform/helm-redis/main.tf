provider "helm" {
  kubernetes {
    host                   = var.aks_host_endpoint
    client_certificate     = var.aks_client_certificate
    client_key             = var.aks_client_key
    cluster_ca_certificate = var.aks_cluster_ca_certificate
  }
}

resource "helm_release" "keda" {
  name             = "redis"
  namespace        = "redis"
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "redis"
  create_namespace = true

  set {
    name  = "auth.enabled"
    value = "true"
  }

  set {
    name  = "auth.password"
    value = "admin"
  }

  set {
    name  = "global.redis.password"
    value = "admin"
  }
}
