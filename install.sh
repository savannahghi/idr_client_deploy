#!/usr/bin/env bash

# Declare and set defaults for supported (env) variables. These variables can be used to change/customize the installation of the application.
declare -A SupportedVariables
SupportedVariables[IDR_DEPLOY_BRANCH]=main
SupportedVariables[FORCE_APP_DOWNLOAD]=no

# Declare each supported variable and set it's default value if the variable wasn't provided at script invocation.
# i.e The for loop below essentially does the following checks and/or declarations for each variable and default value combination defined in "SupportedVariables".
# 
#         # E.g. This will set "main" as the IDR deploy branch when one isn't provided.
#         if [[ ! -v IDR_DEPLOY_BRANCH || ! -n "$IDR_DEPLOY_BRANCH" ]]; then
#             IDR_DEPLOY_BRANCH="main"
#         fi

for key in "${!SupportedVariables[@]}"
do
    if [[ ! -v $key || ! -n "${!key}" ]]; then
        declare "$key"="${SupportedVariables[$key]}"
    fi
done

# Source env variables regarding OS details e.g NAME, VERSION_ID
. /etc/os-release


echo "=========================================================================="
echo "Host and installation parameters"
echo $'==========================================================================\n'
echo "HOST OS NAME:       $NAME"
echo "HOST OS VESRION:    $VERSION"
echo "IDR DEPLOY BRANCH:  $IDR_DEPLOY_BRANCH"
echo "FORCE APP DOWNLOAD: $FORCE_APP_DOWNLOAD"


echo $'\n\n=========================================================================='
echo "Install Ansible and other dependencies for Ubuntu $VERSION_ID"
echo $'==========================================================================\n'
apt update
# Check ubuntu versions and add the appropriate Ansible repo 
if [[ $VERSION_ID == "16.04" ]]
then
    apt install software-properties-common -y
    add-apt-repository --yes --update ppa:ansible/ansible-2.9
elif [[ $VERSION_ID == "18.04" ]]
then
    add-apt-repository --yes --update ppa:ansible/ansible-2.9
fi
apt install ansible cron desktop-file-utils unzip -y


# Download the IDR Client Installation Playbook Archive
echo $'\n\n=========================================================================='
echo "Download IDR Client installation playbook archive" 
echo $'==========================================================================\n'
curl -L https://github.com/savannahghi/idr_client_deploy/archive/refs/heads/${IDR_DEPLOY_BRANCH}.zip -o /tmp/idr_client_deploy.zip


# Extract the Installation Playbook Archive
echo $'\n\n=========================================================================='
echo "Extract the installation playbook archive"
echo $'==========================================================================\n'
unzip -o /tmp/idr_client_deploy.zip -d /tmp/


# Run the Playbook
echo $'\n\n=========================================================================='
echo "Run the playbook"
echo $'==========================================================================\n'
cd /tmp/idr_client_deploy-${IDR_DEPLOY_BRANCH}/playbook && ansible-playbook -i inventory idr_client.yml \
    --ask-vault-pass \
    --ask-become-pass -vvv \
    -e "{\"force_app_download\": $(if [[ $FORCE_APP_DOWNLOAD == "yes" ]]; then echo "true"; else echo "false"; fi) }"

