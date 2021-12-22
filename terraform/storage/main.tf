terraform {
  required_version = ">= 1.0.11"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  backend "azurerm" {
    key = "sonarcube_db.tfstate"
  }
}

data "azurerm_key_vault" "sonarqube" {
  name = var.keyvault_name
  resource_group_name = var.keyvault_rg_name
}

data "azurerm_key_vault_secret" "db_secret" {
  key_vault_id = data.azurerm_key_vault.sonarqube.id
  name = var.keyvault_db_password_secret_name
}

# See https://github.com/hashicorp/terraform/issues/2283
locals {
  common_tags = tomap({
    "stage" = var.stage,
    "label" = "sonarqube"
  })
  db_password = data.azurerm_key_vault_secret.db_secret.value
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "sonarqube_database" {
  name     = "sonarqube-database-${var.stage}"
  location = var.location
  tags = local.common_tags
}

resource "azurerm_postgresql_server" "sonarqube" {
  name                = "mysonarqube-${var.stage}"
  location            = azurerm_resource_group.sonarqube_database.location
  resource_group_name = azurerm_resource_group.sonarqube_database.name

  administrator_login          = var.db_user
  administrator_login_password = local.db_password

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 10240
  infrastructure_encryption_enabled = false

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  
  tags = local.common_tags
}

resource "azurerm_postgresql_firewall_rule" "sonarqube" {
  name                = "mysonarqube-firewall-${var.stage}"
  resource_group_name = azurerm_resource_group.sonarqube_database.name
  server_name         = azurerm_postgresql_server.sonarqube.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_database" "sonarqube" {
  name                = "mysonarqube-${var.stage}"
  resource_group_name = azurerm_resource_group.sonarqube_database.name
  server_name         = azurerm_postgresql_server.sonarqube.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
