### Overview
This a simple playbook to automate idr client installation. IDR client is a service application that automates running data extraction from a pre-defined database. This playbook should be run a server that hosts the database from which the client will extract data.


### Download and Run the playbook.
```
- terminal$ curl -L https://github.com/savannahghi/idr_client_deploy/archive/refs/heads/main.zip -o idr_client.zip
- terminal$ unzip idr_client.zip
- terminal$ cd idr_client_deploy-main
- terminal$ chmod +x play.sh
- terminal$ ./play.sh
```
#### On a successful run, expect:
- Installation of ansible 2.9+
- Creation of new user on the system
- Creation of a default folder in which to run client app; the folder contains:
  client app, config.yaml, logs directory and run.sh file.
- Creation of cron task that is scheduled to run everyday at 3.00 am

#### Editing configuration file:

```
- server$ sudo -u idr -i  // open terminal as user idr using admin password.
- server@idr$ cd /home/idr/idr_client  // navigate to root directory of the application.
- server@idr_client$ nano config.yaml  // open config file for editing. 
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
server@idr$ crontab -e  // open cron file
server@idr$ tail -f /home/idr/idr_client/extracts.log  // log the changes on the log file in real time.
```
#### Playbook secrets

You may want to read/change the variables used in the playbook; 
> decryption_key is the secret word that will help you encrypt/decrypt the variables. 
```
- idr_client_deploy-main$ touch .vaultpass && echo **decryption_key** > .vaultpass 
- idr_client_deploy-main$ cd playbook 
- playbook$ ansible-vault encrypt group_vars/all/vault.yml --vault-id ../.vaultpass 
- playbook$ ansible-vault decrypt group_vars/all/vault.yml --vault-id ../.vaultpass 
```

#### Finally
After confirming everything is working correctly;
- Remember to encrypt decrypted variables.
- Remember to change back crontab run time back to 3.00 am everyday. i.e  0 3 * * *


