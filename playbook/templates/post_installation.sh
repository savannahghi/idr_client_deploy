#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Declare and set defaults for supported (env) variables. These variables can
# be used to change/customize the installation of the application.
declare -A DEFAULT_SETTINGS
DEFAULT_SETTINGS[EDITOR]=nano  # Set to null to disable config file opening at the end of the installation.

# Declare each supported variable and set it's default value if the variable
# wasn't provided at script invocation.
# i.e The for loop below essentially does the following checks and/or
# declarations for each variable and default value combination defined in
# "DEFAULT_SETTINGS".
# 
#         # E.g. This will set "main" as the IDR deploy branch when one isn't
#         # provided.
#         if [[ ! -v IDR_DEPLOY_BRANCH || ! -n "$IDR_DEPLOY_BRANCH" ]]; then
#             IDR_DEPLOY_BRANCH="main"
#         fi

for key in "${!DEFAULT_SETTINGS[@]}"
do
    if [[ ! -v $key || ! -n "${!key}" ]]; then
        declare "$key"="${DEFAULT_SETTINGS[$key]}"
    fi
done


sudo -u "{{ app_user }}" $EDITOR "{{ app_config_dir }}/config.yml"
