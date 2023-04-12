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
sudo bash -c "$(curl -L https://raw.githubusercontent.com/savannahghi/idr_client_deploy/main/install.sh)"
```

> **NOTE:** The instructions and examples from this section henceforth assume that the default or typical installation paramaters are used. If that's not the case, replace those values as appropriate. If in doubt, confirm the values in use from the appropriate `playbook\group_vars\**\*.yml` file(s). 

This should perform the following actions:
- Installation of `Ansible 2.9+`, `unzip`, `cron` if they aren't already installed.
- Creation of a new user on the system used to run the application. Typically, this user will be  named `idr`.
- Creation of a folders to store the application configurations and logs. Typically, these will be `/etc/idr_client/` and `/var/log/idr_client` respectively.
- Check if there is an existing IDR Client installation and if so, which version. If the [latest version](https://github.com/savannahghi/idr-client/releases) of the client is already installed, the installation ends here and the rest of the steps are skipped.
- Download and install the latest version on the IDR Client on the host.
- Creation of cron task on the application user scheduled to run every day at a random time within the hours of 3:00 am, 9:00 am and 3:00 pm.
- Add desktop entries allowing the application to be easily invoked from the host's desktop environment.

After a successful installation, you will need to `edit the configuration file` with host specific parameters. As this is an important step before using the client, the default behavior of the installation script is to open the configuration file for editing after the installation. If this doesn't happen, for some reason, you can open the config file for editing using the following command:

```bash
sudo -u idr nano /etc/idr_client/config.yml
```

Ensure that the config variables match those of the host, especially the `SQL DATA SOURCES SETTINGS` and `FACILITY DETAILS` sections. Once you are done, save the new changes using `CTRL+s`  and exit from the editor using the `CTRL+x`.


## Running the IDR Client
After a successful installation, the client can be run using the following command.

```bash
sudo -u idr /usr/local/bin/run_idr_client
```


## Working with KenyaEMR as a Data Source (Scheduling ETL)
This section details how to configure `KenyaEMR` to ensure data in the `kenyaemr_etl` database tables is refreshed periodically.
- Open link below to show list of existing schedulers
 `http://localhost:8080/openmrs/admin/scheduler/scheduler.list`
- If there is already a scheduler for etl table tick the checkbox, scroll to the bottom and click stop.
    - Click on it to open for edit
    - Ensure Schedulable class is set to: `org.openmrs.logic.task.InitializeLogicRuleProvidersTask`
    - Click on `Schedule` to set the start time at `23:23:59`
    - Ensure to check `Start on startup`, Set Repeat interval to: `1` `days` -> save
    - Go back to list of schedulers, check the etl one, scroll to the bottom to start.
- If it does not exist, create one by double clicking on `Add task`;
    - Give it a name e.g Etl task
    - Paste Schedulable class as `org.openmrs.logic.task.InitializeLogicRuleProvidersTask`
    - Click on `schedule` and repeat the values as above.
    - Same steps as previous.

## Optional Tasks
Everything in this section is optional and requires a lot of care or else you risk breaking the installation process. Users are **highly discouraged** from attempting these tasks unless they know what they are doing!

Proceed with **CAUTION**.

### 1. Tweaking the Cron Entry
Tweak cron service to run every minute \
e.g for this do; \
change the running period to  * * * * * /cron/command. \
> **NOTE:** Be careful to edit the correct crontab. It should be specific to the application user( typically named `idr`) .

```bash
sudo -u idr crontab -e  # open cron file for the user named 'idr'
```
### 2. Change the Installation Parameters
The installation script is designed to be tunable on the fly using `bash` variables. These can either be set on the parent shell itself using the `export` command or by prepending them on the shell that runs the installation script on invocation. This allows the installation to be customized to suite different hosts and environments with minimal effort. The only downside to this approach is that it is limited to a few customizations. For more broad customizations, see the section below on using playbook variables.

**Examples**

Below are examples of how both of these approaches can be used to install the client from a different branch *(called `develop` in the examples)* other than the default:

```bash
# Using the export declaration command
export IDR_DEPLOY_BRANCH=develop
# The '-E' option on sudo is crucial for this to work
sudo -E bash -c "$(curl -L https://raw.githubusercontent.com/savannahghi/idr_client_deploy/main/install.sh)"
```

```bash
# Prepending a variable on a shell
sudo IDR_DEPLOY_BRANCH=develop bash -c "$(curl -L https://raw.githubusercontent.com/savannahghi/idr_client_deploy/main/install.sh)"
```

Use whatever approach suits you best.

**Supported Variables**
| Variables                    	| Default Value 	| Explanation                                                                                                                                                                                                                                                                                                                                                                                                                            	|
|------------------------------	|---------------	|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| FORCE_APP_DOWNLOAD           	| no            	| The default behavior of the installation process is to skip a fresh installation of the client if the latest version is already installed. By setting this variable to `yes`, a fresh installation of the client will be performed regardless of the current installation status of the client.                                                                                                                                        	|
| IDR_DEPLOY_BRANCH            	| main          	| Defines the branch(on this repository) from which to deploy/install the IDR Client from. This can be useful for example when testing new changes on the installation playbook.                                                                                                                                                                                                                                                         	|
| LOCAL_BINARY_PATH            	|               	| Specifies an alternate location on the host filesystem from where to get the app binary from instead of downloading the binary from github(the default behavior). This is useful in locations where the internet connectivity is unreliable and downloading the binary is not ideal or is slow. Set this variable to a non-empty string to trigger this behavior. When not empty or `None`, the given string **must** be a valid path. 	|
| SKIP_DESKTOP_ENTRIES         	| no            	| By default, the installation process installs desktop entries on the host making it easy to launch the application from a graphical user interface. This can be disabled for hosts where it's not applicable by setting the value of this variable to `yes`.                                                                                                                                                                           	|
| SKIP_POST_INSTALLATION_TASKS 	| no            	| The default behavior of the installation process is to run post installation tasks that among other things open the application configuration file for editing and performs some clean up. This can be disabled by setting this value to `yes`.                                                                                                                                                                                        	|

There are more variables to come.
### 3. Change the Playbook Variables

If the installation script parameters aren't granular enough for your needs, you may want to change the playbook's variables which give you more control over the installation process. This can be achieved by modifying the entries defined in the `yaml` files located at `playbook\group_vars\**\` directories. The contents in `playbook\group_vars\**\vars.yaml` are plain text while those in `playbook\group_vars\**\vault.yml` are encrypted. The later files have to be decrypted before any modifications can be performed to their contents. This can be done using the following command:

```bash
# Assuming  you are in this repository's root folder, i.e The one with the README.md file
ansible-vault decrypt playbook/group_vars/**/*vault.yml --ask-vault-pass 
```

When asked, provide the vault password (to be communicated offline). When done, encrypt the file again using the command:


```bash
# Assuming  you are in this repository's root folder, i.e The one with the README.md file
ansible-vault encrypt playbook/group_vars/**/*vault.yml --ask-vault-pass 
```

> **CAUTION:** After confirming everything is working correctly;
> - Remember to encrypt if you have decrypted variables.
> - Remember to change back crontab run time back to 3.00 am everyday. i.e  0 3,9,15 * * *

