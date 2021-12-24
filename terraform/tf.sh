#! /bin/bash

CUR_DIR_TF=$(pwd)

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn 

TF_CONFIG_DIR=$2
if [[ ! -d "./${TF_CONFIG_DIR}" ]]; then
    echo "The config '${TF_CONFIG_DIR}' doesn't exist"
    echo "These config folders are available:"
    ls .
    exit 1
fi
cd "$TF_CONFIG_DIR" || exit 1

TF_COMMAND=$3

subCommandsWithVars=(apply destroy plan)
subCommandsWithBackend=(init)
subCommandsWithoutVars=(output)

# shellcheck disable=SC2199
if [[ " ${subCommandsWithVars[@]} " =~ ${TF_COMMAND} ]]; then
  # shellcheck disable=SC2145
  TF_VAR_FILE_CONFIG="-var-file=../../config/stages/${STAGE}/default.tfvars"
  # shellcheck disable=SC2145
  echo "Running in $(pwd): terraform $TF_COMMAND $TF_VAR_FILE_CONFIG ${@:4}"
  terraform "$TF_COMMAND" "$TF_VAR_FILE_CONFIG" "${@:4}"
elif [[ " ${subCommandsWithoutVars[@]} " =~ ${TF_COMMAND} ]]; then
  # shellcheck disable=SC2145
  terraform "$TF_COMMAND" "${@:4}"
elif [[ " ${subCommandsWithBackend[@]} " =~ ${TF_COMMAND} ]]; then
  # shellcheck disable=SC2145
  echo "Running in $(pwd): terraform init ${@:4} with remote backend in $TF_BACKEND_STORAGE_NAME"
  terraform init \
           -reconfigure \
           -backend-config="resource_group_name=$TF_BACKEND_RG_NAME" \
           -backend-config="storage_account_name=$TF_BACKEND_STORAGE_NAME" \
           -backend-config="container_name=$TF_BACKEND_STORAGE_CONTAINER_NAME" \
           -backend-config="subscription_id=${TF_VAR_subscription_id}" \
           "${@:4}"
else
  echo "Unknown terraform command $TF_COMMAND"
  exit 1
fi

cd "$CUR_DIR_TF" || exit 1