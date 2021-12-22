output "webserver_ip" {
  value = azurerm_linux_virtual_machine.sonarqube.public_ip_address
}

output "public_ip" {
  value = azurerm_public_ip.sonarqube.ip_address
}

output "dns_record" {
  value = azurerm_dns_a_record.sonarqube.fqdn
}