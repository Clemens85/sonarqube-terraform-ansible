#! /bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

SP_NAME="SonarDnsValidator-${STAGE}"

spExistsResponse=$(az ad sp list --display-name "$SP_NAME" --query "[?appDisplayName == '$SP_NAME']")
if [[ "$spExistsResponse" != "[]" ]]; then
    echo "$SP_NAME exists already, nothing needs to be done!"
    exit 0
fi
   
SCOPE="/subscriptions/${TF_VAR_existing_dns_subscription_id}/resourceGroups/${TF_VAR_existing_dns_zone_resource_group}/providers/Microsoft.Network/dnszones/${TF_VAR_existing_dns_zone_name}"
echo "$SP_NAME does not exist yet, so create it with scope $SCOPE"
response=$(az ad sp create-for-rbac --name "$SP_NAME" --role "DNS Zone Contributor" \
                                        --scopes "/subscriptions/${TF_VAR_existing_dns_subscription_id}/resourceGroups/${TF_VAR_existing_dns_zone_resource_group}/providers/Microsoft.Network/dnszones/${TF_VAR_existing_dns_zone_name}" \
                                        --query "[appId,password,tenant]" --output tsv)

responseAsArray=($response)
APP_ID="${responseAsArray[0]}"
SECRET="${responseAsArray[1]}"
TENANT_ID="${responseAsArray[2]}"

echo "Add AZUREDNS-CLIENTSECRET to our key-vault $TF_VAR_keyvault_name"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "AZUREDNS-CLIENTSECRET" --value "$SECRET"
echo "Add AZUREDNS-APPID to our key-vault $TF_VAR_keyvault_name"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "AZUREDNS-APPID" --value "${APP_ID}"
echo "Add AZUREDNS-APPID to our key-vault $TF_VAR_keyvault_name"
az keyvault secret set --subscription "$TF_VAR_subscription_id" --vault-name "$TF_VAR_keyvault_name" --name "AZUREDNS-TENANTID" --value "${TENANT_ID}"

