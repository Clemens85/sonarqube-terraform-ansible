terraform {
  required_version = ">= 1.0.11"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  backend "azurerm" {
    key = "sonarqube_app.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}


provider "azurerm" {
  alias = "prod_dns"
  subscription_id = var.existing_dns_subscription_id
  features {
  }
}

# See https://github.com/hashicorp/terraform/issues/2283
locals {
  common_tags = tomap({
    "stage" = var.stage,
    "label" = "sonarqube"
  })
}

resource "azurerm_resource_group" "sonarqube_app" {
  name     = "sonarqube-app-${var.stage}"
  location = var.location
  tags = local.common_tags
}

resource "azurerm_virtual_network" "sonarqube" {
  name                = "sonarqube-network-${var.stage}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sonarqube_app.location
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  tags = local.common_tags
}

resource "azurerm_subnet" "sonarqube_app" {
  name                 = "sonarqube-subnet-app-${var.stage}"
  resource_group_name  = azurerm_resource_group.sonarqube_app.name
  virtual_network_name = azurerm_virtual_network.sonarqube.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "sonarqube" {
  name                = "sonarqube-pip-${var.stage}"
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  location            = azurerm_resource_group.sonarqube_app.location
  allocation_method   = "Dynamic"
  domain_name_label = "mysonarqube"
  tags = local.common_tags
}

resource "azurerm_network_interface" "sonarqube_public" {
  name                = "sonarqube-nic-public-${var.stage}"
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  location            = azurerm_resource_group.sonarqube_app.location

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.sonarqube_app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonarqube.id
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "sonarqube_nsg" {
  name                = "sonarqube_nsg-${var.stage}"
  location            = azurerm_resource_group.sonarqube_app.location
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  tags = local.common_tags
}

resource "azurerm_network_security_rule" "sonarqube_http" {
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  network_security_group_name = azurerm_network_security_group.sonarqube_nsg.name
  access                     = "Allow"
  direction                  = "Inbound"
  name                       = "http"
  priority                   = 101
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_port_range     = "80"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "sonarqube_https" {
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  network_security_group_name = azurerm_network_security_group.sonarqube_nsg.name
  access                     = "Allow"
  direction                  = "Inbound"
  name                       = "https"
  priority                   = 100
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_port_range     = "443"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "sonarqube_ssh" {
  resource_group_name = azurerm_resource_group.sonarqube_app.name
  network_security_group_name = azurerm_network_security_group.sonarqube_nsg.name
  access    = "Deny"
  direction = "Inbound"
  name      = "ssh"
  priority  = 150
  protocol  = "TCP"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "22"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.sonarqube_public.id
  network_security_group_id = azurerm_network_security_group.sonarqube_nsg.id
}

data "azurerm_dns_zone" "my_existing_dns_zone" {
  provider = azurerm.prod_dns
  name                = var.existing_dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
}


resource "azurerm_dns_a_record" "sonarqube" {
  provider = azurerm.prod_dns
  name                = "sonarqube-${var.stage}"
  zone_name           = data.azurerm_dns_zone.my_existing_dns_zone.name
  resource_group_name = var.existing_dns_zone_resource_group
  ttl                 = 90
  target_resource_id = azurerm_public_ip.sonarqube.id
  depends_on = [azurerm_public_ip.sonarqube, azurerm_linux_virtual_machine.sonarqube]
  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "sonarqube" {
  name                            = "sonarqube-vm-${var.stage}"
  resource_group_name             = azurerm_resource_group.sonarqube_app.name
  location                        = azurerm_resource_group.sonarqube_app.location
  size                            = "Standard_F2"
  admin_username                  = "sonarqube-admin"
  network_interface_ids = [
    azurerm_network_interface.sonarqube_public.id
  ]

  admin_ssh_key {
    username = "sonarqube-admin"
    public_key = file("../../ssh-keys-allowed/your-own-ssh-publickey.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = filebase64("./cloud-init.sh")

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    local.common_tags,
    tomap({
      "webserver" = "true",
      "version" = "9.2.0"
    })
  ) 
}

# Get the keyvault that was created outside Terraform containing our secrets we need:
data "azurerm_key_vault" "sonarqube" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg_name
}

# Give our VM (which has a SystemAssigned identity) read-access to our KeyVaults secrets => No further auth is then needed on this VM for accessing the secrets
resource "azurerm_key_vault_access_policy" "sonarqube_vm_access" {
  key_vault_id = data.azurerm_key_vault.sonarqube.id
  key_permissions = [ "Get", "List" ]
  secret_permissions = [ "Get", "List" ]
  object_id = azurerm_linux_virtual_machine.sonarqube.identity[0].principal_id
  tenant_id = azurerm_linux_virtual_machine.sonarqube.identity[0].tenant_id
}
