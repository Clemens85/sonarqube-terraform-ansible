variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

variable "subscription_id" {
  description = "The Azure Subscription in which all resources in this example should be created."
}

variable "stage" {
  description = "This is identical to the subscription_id but provides a human understandable description of the current stage and is used when naming resources"
}

variable "db_user" {
  default = "sonarqube"
}

variable "keyvault_name" {
  description = "Needed for fetching the DB password secret => Will be populated by wrapper script"
}
variable "keyvault_db_password_secret_name" {
  description = "Needed for fetching the DB password secret => Will be populated by wrapper script"
}
variable "keyvault_rg_name" {
  description = "Needed for fetching the DB password secret => Will be populated by wrapper script"
}
