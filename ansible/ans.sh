#! /bin/bash

CUR_DIR=$(pwd)
cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

source ../config/config.sh

STAGE=$1
# This will provide some important Environment variables that will be used later on e.g. for logging in to Azure with the proper subscription
setupValidEnvironmentVars "${STAGE}"
ensureLoggedIn 

../scripts/util/allow-ssh-access.sh "$STAGE"

# Workaround when running in WSL (works also on Linux), we just write the ansible.cfg every time in our home dir 
# which has appropriate permissions and set this cfg file to be used by setting the ANSIBLE_CONFIG variable
# See also https://docs.ansible.com/ansible/devel/reference_appendices/config.html#cfg-in-world-writable-dir
mkdir -p ~/ansible-sonarqube-config
cat << EOF > ~/ansible-sonarqube-config/ansible.cfg
[defaults]
remote_user = sonarqube-admin
host_key_checking = False
deprecation_warnings = False
nocows = 1
EOF
export ANSIBLE_CONFIG="$HOME/ansible-sonarqube-config/ansible.cfg"
# End workaround

DB_SERVER=$(../terraform/tf.sh "$STAGE" storage output -raw db_server)
DB_NAME=$(../terraform/tf.sh "$STAGE" storage output -raw name)
DNS_NAME=$(../terraform/tf.sh "$STAGE" app output -raw dns_record)
if [[ $DNS_NAME == *. ]]; then # The DNS record result ends typically with a dot (example: "mydomain.de.") => Hence we remove this last ".":
  DNS_NAME=${DNS_NAME::-1}
fi

# Without export it will not work... you will get very strange errors when using the dynamic inventory...
export AZURE_SUBSCRIPTION_ID="${TF_VAR_subscription_id}"
export AZURE_CLIENT_ID=$(az keyvault secret show --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-APPID" --query "value" --output tsv)
export AZURE_SECRET=$(az keyvault secret show --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-CLIENTSECRET" --query "value" --output tsv)
export AZURE_TENANT=$(az keyvault secret show --vault-name "$TF_VAR_keyvault_name" --name "TF-ANSIBLE-TENANTID" --query "value" --output tsv)

ANSIBLE_EXTRA_VARS="stage=${STAGE} key_vault_name=${TF_VAR_keyvault_name} db_secret_name=${TF_VAR_keyvault_db_password_secret_name} db_server=${DB_SERVER} db_name=${DB_NAME} dns_name=${DNS_NAME} dns_subscription_id=${TF_VAR_existing_dns_subscription_id} dns_email=${DNS_EMAIL}"

# Call our playbook to provision the VM with those env variables:
ansible-playbook -i inventory_azure_rm.yml instance.yml --extra-vars="$ANSIBLE_EXTRA_VARS" -vv
playbookSucceeded=$?

unset AZURE_SUBSCRIPTION_ID
unset AZURE_CLIENT_ID
unset AZURE_SECRET
unset AZURE_TENANT

if [ $playbookSucceeded -eq 0 ]; then
  ../scripts/util/remove-ssh-access.sh "$STAGE"
fi

cd "$CUR_DIR" || exit 1
