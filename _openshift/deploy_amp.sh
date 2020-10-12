#!/bin/bash

# Set the ANSIBLE_ROLES_PATH to drop the roles required for the playbook locally:
# export ANSIBLE_ROLES_PATH=$(readlink -f roles)
# echo "ANSIBLE_ROLES_PATH set to: $ANSIBLE_ROLES_PATH"

# Make sure that the roles required by the playbook are installed (force the right versions
# if that's required):
ansible-galaxy install -r roles/requirements.yml --force

# Get the current user's OCP access token:
OCP_TOKEN=$(oc whoami -t)
echo "User's OCP token => $OCP_TOKEN"

# Call the local `deploy` script which runs the actual `ansible-galaxy` command
# to apply the templates to the OCP cluster.  Note the environment variables
# ("-e") passed to the `ansible-playbook` command in the `deploy` script.

./deploy -e ocp_user='pfoster@nvsconsulting.io' \
         -e ocp_token="$OCP_TOKEN" \
         -e ocp_url='https://ocp.nvsconsulting.io:8443' \
         -e docker_repo_url='quay-enterprise-quay-enterprise.ocp.nvsconsulting.io' \
         -e namespace_name='itorders-embedded-kie' \
         -e image_namespace_name='philip' \
         -e filter_tags='deploy' \
         -e include_tags='deploy' \
         -e service='itorders-embedded-kie' \
         -e apps_subdomain='ocp.nvsconsulting.io'
