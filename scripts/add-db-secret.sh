#! /bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

if [[ $# -ne 2 ]]; then
  echo "Error: Must pass stage and a password as first and second arguments!!"
  exit 1
fi

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

echo "Adding Secret $TF_VAR_keyvault_db_password_secret_name into Vault $TF_VAR_keyvault_name with value $2"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "$TF_VAR_keyvault_db_password_secret_name" --value "$2"