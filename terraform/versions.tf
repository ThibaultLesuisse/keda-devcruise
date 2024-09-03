terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.1"
    }
  }
  required_version = "~> 1.3"
}