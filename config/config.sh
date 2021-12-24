#! /bin/bash

export DOCKER_IMAGE="terraform-ansible-cli-image"

# These are the same for every stage:
export TF_VAR_location="westeurope"
export TF_VAR_existing_dns_zone_name="EXISTING_DNS_ZONE_NAME"
export TF_VAR_existing_dns_zone_resource_group="EXISTING_DNS_ZONE_PARENT_RESOURCE_GROUP"
export TF_VAR_existing_dns_subscription_id="YOUR_SUBSCRIPTION_ID_DNS"
export DNS_EMAIL="YOUR-EMAIL@PROVIDER.DE"

ensureLoggedIn () {
  az account show >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      az login --allow-no-subscriptions >/dev/null
  fi
  az account set --subscription "${TF_VAR_subscription_id}" >/dev/null 2>&1
}

setupValidEnvironmentVars () {
  passedStage=$1
  if [[ -z "$passedStage" ]]; then
    echo "Error: Must pass a stage as first parameter"
    exit 1
  fi
  configDir=$(dirname "${BASH_SOURCE[0]}")
  if [[ ! -d "${configDir}/stages/${passedStage}" ]]; then
      echo "The stage '${passedStage}' doesn't exist under config/stages"
      echo "These stages are available:"
      ls "${configDir}/stages/"
      exit 1
  fi
  
  subscriptionId=$(grep subscription_id "${configDir}/stages/${passedStage}/default.tfvars" | awk -F= '{print $2}' | tr -d '"' | xargs)
  export TF_VAR_subscription_id="$subscriptionId"
  
  export TF_BACKEND_RG_NAME="sonarqube_tf_backend_rg_${passedStage}"
  export TF_BACKEND_STORAGE_NAME="sonartfbackend${passedStage}"
  export TF_BACKEND_STORAGE_CONTAINER_NAME="sonartfbackend${passedStage}"
  
  export TF_VAR_keyvault_rg_name="sonarqube_keyvault_rg_${passedStage}"
  export TF_VAR_keyvault_name="sonar-keyvault-${passedStage}"
  export TF_VAR_keyvault_db_password_secret_name="sonar-db-password-${passedStage}"
}