variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

variable "subscription_id" {
  description = "The Azure Subscription in which all resources should be created."
}

variable "stage" {
  description = "This is identical to the subscription_id but provides a human understandable description of the current stage and is used when naming resources"
}

variable "existing_dns_zone_name" {
  description = "The name of the existing DNS zone into which to place the new DNS A record => Will be populated by wrapper script"
}

variable "existing_dns_zone_resource_group" {
  description = "The name of the parent resource group of the existing DNS zone into which to place the new DNS A record => Will be populated by wrapper script"
}

variable "existing_dns_subscription_id" {
  description = "The subscription of the existing DNS zone into which to place the new DNS A record => Will be populated by wrapper script"
}

variable "keyvault_name" {
  description = "The name of the KeyVault which contains the secrets to be used later on the created VM => Will be populated by wrapper script"
}

variable "keyvault_rg_name" {
  description = "The name of the parent resource group of the KeyVault which contains the secrets to be used later on the created VM => Will be populated by wrapper script"
}