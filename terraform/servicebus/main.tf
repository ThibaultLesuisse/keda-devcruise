resource "azurerm_servicebus_namespace" "keda_servicebus" {
  name                = "keda-euricom-servicebus-namespace"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "keda-queue" {
  name                 = "keda_servicebus_queue"
  namespace_id         = azurerm_servicebus_namespace.keda_servicebus.id
  partitioning_enabled = false
}
