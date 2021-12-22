output "name" {
  value = azurerm_postgresql_database.sonarqube.name
}

output "db_server" {
  value = azurerm_postgresql_server.sonarqube.fqdn
}