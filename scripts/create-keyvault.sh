#! /bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

echo "Creating Resource Group in $TF_VAR_keyvault_rg_name in ${TF_VAR_subscription_id}"
az group create -l "$TF_VAR_location" -n "$TF_VAR_keyvault_rg_name" --subscription "$TF_VAR_subscription_id"

echo "Creating KeyVault with name $TF_VAR_keyvault_name"
az keyvault create --location "$TF_VAR_location" --name "$TF_VAR_keyvault_name" --resource-group "$TF_VAR_keyvault_rg_name" --subscription "$TF_VAR_subscription_id"

