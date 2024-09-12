terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.1"
    }
  }
  backend "azurerm" {
      resource_group_name  = "common"
      storage_account_name = "terraformstatethibault"
      container_name       = "devcruise"
      key                  = "terraform.tfstate"
  }
  required_version = "~> 1.3"
}