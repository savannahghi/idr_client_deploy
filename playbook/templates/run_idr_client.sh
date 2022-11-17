#!/bin/bash

# This will ensure that the logs folder ({{ app_logs_dir }}) is always writable
#  by the application user group ({{ app_user_group }}) regardless of the umask
#  config of the executing user.
umask 0005
{{ app_installation_dir }}/idr_client -c {{ app_config_dir }}/config.yaml 

