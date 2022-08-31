#### How to run the playbook.
Check the *ansible --version* of the host machine on which you're deploying the client.\
Use the commands relevant to your ubuntu version to install/update ansible if the ansible version is less than **2.9.0**
#### Installing ansible on ubuntu distros. 

**ubuntu 16.04 ansible installation**

sudo apt update \
sudo apt install software-properties-common -y \
sudo add-apt-repository --yes --update ppa:ansible/ansible \
sudo apt install ansible -y 

**ubuntu 18.04 ansible installation**

sudo apt update     
sudo add-apt-repository ppa:ansible/ansible-2.10 -y \
sudo apt install ansible -y 


**ubuntu 20.04 ansible installation**

sudo apt update \
sudo apt install ansible 

#### Decrypt/Encrypt variables
playbook$ ansible-vault encrypt group_vars/all/vault.yml --vault-id ../.vaultpass \
playbook$ ansible-vault decrypt group_vars/all/vault.yml --vault-id ../.vaultpass 

#### Run the playbook

playbook$ ansible-playbook idr_client.yml --vault-id=../.vaultpass --ask-become-pass -vvv

