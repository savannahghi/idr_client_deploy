# Overview
This playbook installs and setups the [IDR Client](https://github.com/savannahghi/idr-client) on Ubuntu 16.04 LTS, 18.04 LTS and 20.04 LTS hosts. IDR Client is an ETL(extract, transform and load) tool that extracts data from data sources such as databases and loads the data to a data sink such as the [IDR Server](https://github.com/savannahghi/idr-server). This playbook should be run on an Ubuntu host that contains data sources with data of interest.


## Prerequisite
Before running the playbook, please ensure that you have curl installed using the following command:
```bash
sudo apt install curl
```

During the installation process, you will also be prompted to provide the following passwords:
- `BECOME password:` This is the password of a `sudoer/admin` on the host. Leave this blank if already running as the root user.
- `Vault password:` This will be provided offline and used to decrypt the encrypted content.

Ensure you have those beforehand.


## Installation

To run the installation, run the following commands:

```bash
sudo curl -L https://raw.githubusercontent.com/savannahghi/idr_client_deploy/main/install.sh | sudo bash
```

> **NOTE:** The instructions and examples from this section henceforth assume that the default or typical installation paramaters are used. If that's not the case, replace those values as appropriate. If in doubt, confirm the values in use from the appropriate `playbook\group_vars\**\*.yml` file(s). 

This should perform the following actions:
- Installation of `Ansible 2.9+`, `unzip`, `cron` if they aren't already installed.
- Creation of new user on the system used to run the application. Typically, this user will be  named `idr`.
- Creation of a folders to store the application configurations and logs. Typically, these will be `/etc/idr_client/` and `/var/log/idr_client` respectively.
- Creation of cron task on the application user that is scheduled to run everyday at 3:00 am, 9:00am and 3:00pm.

After the installation, you will need to edit the configuration file with host specific paramaters. This can be achieved using the command:

```bash
sudo -u idr nano /etc/idr_client/config.yaml
```

Ensure that the config variables match those of the host, especially the `SQL DATA SOURCES SETTINGS` and `FACILITY DETAILS` sections. Once you are done, save the new changes using `CTRL+s`  and exit from the editor using the `CTRL+x`.

> **NOTE(For Developers):** To install the app from a different branch other than `main`, pass the name of the branch to the `bash` command (last command in the pipe), as the variable `IDR_DEPLOY_BRANCH`. For example, to install the app from the `develop` branch, use the following command:
> ```bash
>  sudo curl -L https://raw.githubusercontent.com/savannahghi/idr_client_deploy/main/install.sh | sudo IDR_DEPLOY_BRANCH=develop bash
> ```


## Runing the IDR Client
After a successfull installation, the client can be run using the fillowing command.

```bash
sudo -u idr /usr/local/bin/run_idr_client
```


## Working with KenyaEMR as a Data Source (Scheduling ETL)
This section details how to configure `KenyaEMR` to ensure data in the `kenyaemr_etl` database tables is refreshed periodically.
- Open link below to show list of existing schedulers
 `http://localhost:8080/openmrs/admin/scheduler/scheduler.list`
- If there is already a scheduler for etl table tick the checkbox, scroll to the bottom and click stop.
    - Click on it to open for edit
    - Ensure shedulable class is set to: `org.openmrs.logic.task.InitializeLogicRuleProvidersTask`
    - Click on `schedule` to set the start time at `23:23:59`
    - Ensure to check `Start on startup`, Set Repeat interval to: `1` `days` -> save
    - Go back to list of schedulers, check the etl one, scroll to the bottom to start.
- If it does not exist, create one by double clicking on `Add task`;
    - Give it a name e.g Etl task
    - Paste Shedulable class as `org.openmrs.logic.task.InitializeLogicRuleProvidersTask`
    - Click on `shedule` and repeat the values as above.
    - Same steps as previous.

## Optional Tasks
Everything after this section is optional.

### Tweaking the Cron Entry:
Tweak cron service to run every minute \
e.g for this do; \
change the running period to  * * * * * /cron/command. \
> **NOTE:** Be careful to edit the correct crontab. It should be specifical to the application user( typically named `idr`) .

```bash
sudo -u idr crontab -e  // open cron file
```
### Change the Installation Paramaters

You may want to change the installation paramaters to suite a particular host. This can be achieved by modifying the entries located in the `yaml` files at `playbook\group_vars\**\` directories. The contents in `playbook\group_vars\**\vars.yaml` are plain text while those in `playbook\group_vars\**\vault.yml` are encrypted. The later files have to be decrypted before any modifications can be performed to its contents. This can be done using the following command:

```bash
# Assuming  you are in this repositor's root folder, i.e The one with the README.md file
ansible-vault decrypt playbook/group_vars/**/*vault.yml --ask-vault-pass 
```

When asked, provide the vault password (to be communicated offline). When done, encrypt the file again using the command:


```bash
# Assuming  you are in this repositor's root folder, i.e The one with the README.md file
ansible-vault encrypt playbook/group_vars/**/*vault.yml --ask-vault-pass 
```

> **CAUTION:** After confirming everything is working correctly;
> - Remember to encrypt if you have decrypted variables.
> - Remember to change back crontab run time back to 3.00 am everyday. i.e  0 3,9,15 * * *

