### Overview
This a simple playbook to automate idr client installation. IDR client is a service application that automates running data extraction from a pre-defined database.
This playbook should be run a server that hosts the database from which the client will extract data.

#### Prerequisite:
    - Installed ansible version >= 2.9.0 on the host server.

### Check ansible and Ubuntu version:
    - Start ubuntu terminal and run:
    - terminal$ lsb_release -a  // show ubuntu version
    - terminal$ ansible --release // show ansible version. Command expected to work only if ansible is installed.

### Depending on the output of the previous steps, install/update ansible for your ubuntu distros.
**NOTE:** *Skip this steps if you have ansible >=2.9.0 already installed*

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


### Running the playbook.

#### Download the playbook

    - terminal$ curl -L https://github.com/savannahghi/idr_client_deploy/archive/refs/heads/main.zip -o idr_client.zip
    - terminal$ unzip idr_client.zip
    - terminal$ cd idr_client_deploy-main

#### Playbook secrets

You may want to read/change the variables used in the playbook; 
> decryption_key is the secret word that will help you encrypt/decrypt the variables. 
```
- idr_client_deploy-main$ touch .vaultpass && echo **decryption_key** > .vaultpass 
- idr_client_deploy-main$ cd playbook 
- playbook$ ansible-vault encrypt group_vars/all/vault.yml --vault-id ../.vaultpass 
- playbook$ ansible-vault decrypt group_vars/all/vault.yml --vault-id ../.vaultpass 
```
#### Run the playbook
> Ensure you have the admin password to the server before running the command.
```
playbook$ ansible-playbook idr_client.yml --vault-id=../.vaultpass --ask-become-pass -vvv
```

#### On a successful run, expect:
    - Creation of new user on the system
    - Creation of a default folder in which to run client app; the folder contains:
      client app, config.yaml, logs directory and run.sh file.
    - Creation of cron task that is scheduled to run everyday at 3.00 am

    
#### Editing configuration file:

```
- server$ sudo -u idr -i  // open terminal as user idr using admin password.
- server@idr$ cd /home/idr/idr_client  // navigate to root directory of the application.
- server@idr_client$ vim config.yaml  // open config file for editing. 
  Put the correct values for:
    - REMOTE_SERVER
    - MYSQL_DB_INSTANCE
    - ORG_UNIT_CODE
    - ORG_UNIT_NAME
- server@idr_client$ ./client -c config.yaml  // run the application manually. Successful run should print *Done.* on the terminal.
```

#### Extra actions (Tweak cron for a quick test):
Tweak cron service to run every minute \
e.g for this change running period to  * * * * * /cron/command.
**NOTE:** Be careful to edit the correct crontab. It should be specifically for user idr.
```
server@idr$ crontab -e
```
#### Finally
After confirming everything is working correctly;
- Remember to encrypt decrypted variables.
- Remember to change back crontab run time back to 3.00 am everyday. i.e  0 3 * * *


