output "queue" {
  value = azurerm_servicebus_queue.keda-queue
}

output "servicebus_id" {
  value = azurerm_servicebus_namespace.keda_servicebus.id
}

output "servicebus_connections" {
  value = azurerm_servicebus_namespace.keda_servicebus.default_primary_connection_string
  sensitive = true
}
