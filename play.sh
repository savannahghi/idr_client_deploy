#!/bin/bash

# Create env variables regarding OS details e.g NAME, VERSION_ID

. /etc/os-release

# Check ubuntu versions and install ansible
if [[ $VERSION_ID == "16.04" ]]
then
    echo "Ansible installation for ubuntu "$VERSION_ID
    sudo apt update
    sudo apt install software-properties-common -y
    sudo add-apt-repository --yes --update ppa:ansible/ansible-2.9
    sudo apt install ansible -y
elif [[ $VERSION_ID == "18.04" ]]
then
    echo "Ansible installation for ubuntu "$VERSION_ID
    sudo apt update
    sudo add-apt-repository ppa:ansible/ansible-2.9 -y
    sudo apt install ansible -y
else
    echo "Ansible installation for ubuntu "$VERSION_ID
    sudo apt update
    sudo apt install ansible
fi

# run the playbook
cd playbook && ansible-playbook -i inventory idr_client.yml --vault-id=../.vaultpass --ask-become-pass -vvv

exit 0

