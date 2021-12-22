# 1. Configurations

Edit `config/config.sh` and adapt the following variables:

* TF_VAR_existing_dns_zone_name => Name of already existing DNS zone into which DNS record will be placed
* TF_VAR_existing_dns_zone_resource_group => Parent resource group of this existing DNS zone
* TF_VAR_existing_dns_subscription_id => Subscription of this existing DNS zone
* DNS_EMAIL => Email to be used when issuing SSL certificates with Letsencrpyt

Edit `config/stages/prod/default.tfvars` and `config/stages/sandbox/default.tfvars` and add the respective subscriptionIds of these stages.

# 2. Initial Setup

Build Docker CLI image containing Terraform, Ansible, Azure CLi, ...:
```shell
docker-cli/build-cli-image.sh
```

Paste your SSH public key into `ssh-keys-allowed/your-own-ssh-publickey.pub` and ensure that your home-directory contains the private SSH key (~/.ssh/...).

## Start Docker Container

Run: 
```shell
./cli.sh
``` 
which starts a Docker container in which all subsequent commands will be executed.

## Create Terraform Backend

Need only to be executed once per each stage:

```shell
scripts/create-terraform-backend.sh STAGE
``` 
whereas stage is something like e.g. 'dev' or 'prod'.

## Create Secrets

Need only to be executed once per each stage

### Create KeyVault

```shell
scripts/create-keyvault.sh STAGE
```
whereas stage is something like e.g. 'dev' or 'prod'.

### Create DB password and add it to KeyVault

```shell
scripts/add-db-secret.sh STAGE YOUR_SUPER_SECRET_PASSWORD
``` 
whereas stage is something like e.g. 'dev' or 'prod' and YOUR_SUPER_SECRET_PASSWORD must be a randomly choosen password that you want to use (must meet the password policies regarding special chars, length, ...).

### Create Service Principal for managing DNS entries and add it's Secrets to KeyVault

```shell
scripts/crete-service-principal-dns.sh STAGE
```
whereas stage is something like e.g. 'dev' or 'prod'.

### Create Service Principal for Ansible and add it's Secrets to KeyVault

```shell
scripts/crete-service-principal-ansible.sh STAGE
```
whereas stage is something like e.g. 'dev' or 'prod'.

# 3. Create / Manage Azure Resources

## Init

Initialize terraform backend / state:
```shell
terraform/tf.sh init sandbox storage
terraform/tf.sh init sandbox app
```

Needs only to be executed the very first time when starting to work with Terraform on your local machine.

## Manage Resources

Execute Terraform commands and append the stage and the area (like storage or app).

Examples:
``` shell
terraform/tf.sh plan sandbox storage
terraform/tf.sh apply sandbox storage
terraform/tf.sh plan sandbox app
terraform/tf.sh apply sandbox app
...
```

Storage resources should be existing before executing App.

# 4. Provision VM with SonarQube, SSL, ...

Example:
``` shell
ansible/ans.sh sandbox
```

If call fails with error that host ist not reachable, just try again, this may just be due to Azure was too slow to update it's network security rule for allowing SSH access.

# 5. SSH into VM

Example:
``` shell
scripts/util/ssh-vm sandbox
```

If call fails with error that host ist not reachable, just try again, it should work then (Azure is unfortunately quite slow when it comes to updating network security group rules).






