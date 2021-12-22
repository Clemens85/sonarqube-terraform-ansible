#! /bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

SP_NAME="AnsibleTerraform-${STAGE}"

spExistsResponse=$(az ad sp list --display-name "$SP_NAME" --query "[?appDisplayName == '$SP_NAME']")
if [[ "$spExistsResponse" != "[]" ]]; then
    echo "$SP_NAME exists already, nothing needs to be done!"
    exit 0
fi
   
echo "$SP_NAME does not exist yet, so create it without scope limitation"
response=$(az ad sp create-for-rbac --name "$SP_NAME" --role "Contributor" \
                                    --query "[appId,password,tenant]" --output tsv)

responseAsArray=($response)
APP_ID="${responseAsArray[0]}"
SECRET="${responseAsArray[1]}"
TENANT_ID="${responseAsArray[2]}"

az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-CLIENTSECRET" --value "$SECRET"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-APPID" --value "${APP_ID}"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-TENANTID" --value "${TENANT_ID}"

