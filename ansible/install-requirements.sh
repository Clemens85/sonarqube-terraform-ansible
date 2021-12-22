#! /bin/bash

CUR_DIR=$(pwd)

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

ansible-galaxy install -r requirements.yml --roles-path roles --force --ignore-errors

cd "$CUR_DIR" || exit 1


#ansible all -m ping -i inventory_azure_rm.yml
#ansible-inventory -i inventory_azure_rm.yml --graph
#ansible sonarqube_vm -m ping -i inventory_azure_rm.yml
#ansible sonarqube-vm-sandbox_dfd5 -m debug -a 'var=hostvars' -i inventory_azure_rm.yml