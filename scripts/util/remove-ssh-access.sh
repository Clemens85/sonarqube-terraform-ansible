#! /bin/bash

CUR_DIR_TF=$(pwd)

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn

export MY_IP=`curl -s https://api.ipify.org`

NSG_NAME="sonarqube_nsg-${TF_VAR_stage}"

echo "Removing SSH access network security rule again for ${MY_IP} in ${NSG_NAME}"
az network nsg rule update -g "sonarqube-app-${TF_VAR_stage}" --nsg-name "${NSG_NAME}" -n "ssh" \
                            --source-address-prefixes "*" --access Deny --subscription "${TF_VAR_subscription_id}"

cd "$CUR_DIR" || exit 1 