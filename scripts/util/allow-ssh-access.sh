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

echo "Updating Network security rule in ${NSG_NAME} to allow SSH Access for ${MY_IP}"
az network nsg rule update -g "sonarqube-app-${TF_VAR_stage}" --nsg-name "${NSG_NAME}" -n "ssh" \
                            --source-address-prefixes "$MY_IP/32" --access Allow --subscription "${TF_VAR_subscription_id}"

echo "Listing rules again for 'triggering' refresh in Azure due to it may need some time till above rule is applied..."
az network nsg rule list -g "sonarqube-app-${TF_VAR_stage}" --nsg-name "${NSG_NAME}" --subscription "${TF_VAR_subscription_id}"
# read -p "Wait 3 seconds for changes being applied to Azure..." -t 3

cd "$CUR_DIR" || exit 1