#! /bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

echo "Creating Resource Group $TF_BACKEND_RG_NAME in ${TF_VAR_subscription_id}"
az group create -l "$TF_VAR_location" -n "$TF_BACKEND_RG_NAME" --subscription "${TF_VAR_subscription_id}"

echo "Creating Storage Account in $TF_BACKEND_STORAGE_NAME"
az storage account create -n "$TF_BACKEND_STORAGE_NAME" -g "$TF_BACKEND_RG_NAME" -l "$TF_VAR_location" --subscription "${TF_VAR_subscription_id}" \
                          --sku Standard_LRS --kind BlobStorage --access-tier Cool

echo "Creating Storage Container $TF_BACKEND_STORAGE_NAME"
az storage container create -n "$TF_BACKEND_STORAGE_NAME" --account-name "$TF_BACKEND_STORAGE_CONTAINER_NAME" --subscription "${TF_VAR_subscription_id}"