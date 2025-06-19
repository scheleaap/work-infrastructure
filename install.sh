#!/bin/bash

repo_name=work-infrastructure
repo_url=https://github.com/scheleaap/${repo_name}.git

# Parse command-line arguments
# Source: http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
PREPARE_ENVIRONMENT="true"
EDIT_CONFIG="true"
RUN_PLAYBOOK="true"
while [[ $# -gt 0 ]]
do
  KEY="$1"
  case $KEY in
    -i|--prepare-environment)
    PREPARE_ENVIRONMENT="true"
    ;;
    -I|--skip-prepare-environment)
    PREPARE_ENVIRONMENT="false"
    ;;
    -e|--edit-config)
    EDIT_CONFIG="true"
    ;;
    -E|--skip-edit-config)
    EDIT_CONFIG="false"
    ;;
    -p|--run-playbook)
    RUN_PLAYBOOK="true"
    ;;
    -P|--skip-run-playbook)
    RUN_PLAYBOOK="false"
    ;;
    *)
    # unknown option
    ;;
  esac
  shift # past argument or value
done

echo "PREPARE_ENVIRONMENT: $PREPARE_ENVIRONMENT"
echo "EDIT_CONFIG: $EDIT_CONFIG"
echo "RUN_PLAYBOOK: $RUN_PLAYBOOK"

PATH="$HOME/.local/bin:$PATH"

if [[ "$PREPARE_ENVIRONMENT" == "true" ]]
then
  echo "Installing Pipx"
  sudo apt install --yes pipx

  echo "Installing Ansible"
  pipx install ansible-core

  if [[ ! -d $HOME/${repo_name} ]]; then
    echo "Cloning git repository"
    git clone --depth=1 ${repo_url} $HOME/${repo_name}
  fi

  cd $HOME/${repo_name}

  echo "Installing Ansible collections"
  ansible-galaxy collection install -r requirements.yml

  echo "Installing Ansible roles"
  ansible-galaxy install -r requirements.yml -p roles/
fi

if [[ "$EDIT_CONFIG" == "true" ]]
then
  cd $HOME/${repo_name}

  echo "Allowing user to edit the Ansible configuration"
  cp group_vars/all/vars.yml.sample group_vars/all/vars.yml
  nano group_vars/all/vars.yml
fi

if [[ "$RUN_PLAYBOOK" == "true" ]]
then
  cd $HOME/${repo_name}

  echo "Running Ansible playbook"
  ansible-playbook -i "hosts" site.yml --ask-become-pass
fi
