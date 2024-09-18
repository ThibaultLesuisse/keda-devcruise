variable "aks_host_endpoint" {
  type        = string
  description = "The AKS host endpoint"
  nullable    = false
}

variable "aks_client_certificate" {
  type        = string
  description = "The AKS client certificate"
}

variable "aks_client_key" {
  type        = string
  description = "The AKS client certificate"
}

variable "aks_cluster_ca_certificate" {
  type        = string
  description = "The AKS client certificate"
}