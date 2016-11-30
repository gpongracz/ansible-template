# Getting Started

This template is supposed to live inside a deployable or infrastructure project and can self-update.
To download and bootstrap a new template instance :

```
curl -L https://github.com/simple-machines/ansible-template/archive/master.tar.gz | tar zxv
mv ansible-template-master ansible
cd ansible
echo "12345" > .vaultpassword
ansible-vault create --vault-password-file .vaultpassword roles/dev/vars/secret.yml
ansible-vault create --vault-password-file .vaultpassword roles/prod/vars/secret.yml
```

## Ansible

Requires ansible 2.1+

Install by executing the following command :

 ```
 sudo pip install -U git+https://github.com/ansible/ansible.git@devel#egg=ansible
 sudo pip install -U boto
 sudo pip install -U boto3
 ```

## Adding password file (needed to run example)

```
echo "12345">.vaultpassword
```

## Running the examples
```
./run-playbook dev.yml
./run-playbook prod.yml
```

## Editing the secret variables
```
./editvault.sh dev
./editvault.sh prod
```

## Creating new vault password and encrypting variables

- create your own `.vaultpassword` (never commit this file)
- create your own variable file in `roles/<env>/vars/secret.yml` (replace <env> with dev, prod, test, etc..)
- run the following `ansible-vault encrypt ./roles/<env>/vars/secret.yml --vault-password-file .vaultpassword` (replace <env> with dev, prod, test, etc..)
- for subsequent edits: `./editvault.sh <env>` (replace <env> with dev, prod, test, etc..)



# Directory Structure (aka what goes where)


  - `ansible/`: root folder
    - `run-playbook.sh`: script to run deployment. ex `./run-playbook.sh dev.yml`
    - `editvault.sh`: script to change secret variables ex `./editvault.sh dev` modifies the file: `./dev/vars/secret.yml`. This requires `.vaultpassword` to be present.
    - `.vaultpassword`: contains the password to decrypt the vault. Do not commit this file!
    - `dev.yml, prod.yml, test.yml`: orchestrate deployment. **They should only contain information about the environment (profile) and roles to execute**. Example:

        ```
        - hosts: localhost
          gather_facts: yes
          environment:
            AWS_PROFILE: "my-company-dev"
          roles:
            - dev
            - infra
        ```
    - `dev/, prod/, test/, etc`: directory that contain environment specific **variables**
        - `tasks/main.yml`: File that should be edited to *only* include other variable files.
        - `vars/`: folder containing variables specific to the environment
            - `secret.yml`: encrypted variables (through `editvault.sh`)
            - `main.yml`: main variables
            - `foo.yml`: create as many as you want, but make sure to include them in your `tasks/main.yml`
    - `infra/`: directory that includes all the tasks. Could be seen as a "common" directory
        - `vars/`: define variables that are common. Can refer to your specific
        - `tasks/`: tasks that will be executed by ansible
            - `main.yml`: main file. references variables as defined in `vars` and then references other tasks in the same subfolder.
            - `foo.yml`: create as many as you want, but make sure to include them in your `main.yml` file.

# Shortcuts (alias and functions)

 - `dps`: shortcut for `docker ps`
 - `dl` : get the id of running docker container 
 - `dlog` : get the log of the running container
 - `dlogf` : get the tailing log of the running container
 - `dlogt` : get the log with timestamps of the running container
 - `dlog -ft` : get the log of the running container with tailing and timestamps
 - `dex <command>` : docker execute command (interactive mode) on the running container (ex: `dex bash`)

# Optional Variable overriding

All of the following variables already have a value, and should only be overriden if you require changing their default values. Look into the `default` directory to understand how the default are set.

To override a variable, just declare it in `infra/vars` (for shared variables) or `<env>/vars` (for environment specific). 

## Configure ECS

The following optional variables are often overriden:
- `ecs_environment_variables` : list of environment variables to set (array of name / value)
- `ecs_port_mappings` : list of port mappings to set (array of containerPort / hostPort)
- `ecs_log_driver` : log driver to use to send log to specified location (e.g. splunk, syslog)
- `ecs_log_options` : options to provide based on `ecs_log_driver` value (see docker documentation)

The following optional variables are less often overriden:
- `docker_image_repo` : location of repository to pull from
- `docker_image_name` : image name within the repo
- `docker_image_tag` : tag of the image
- `ecs_taskdefinition_cpu` : task definition cpu (MUST be an int)
- `ecs_taskdefinition_memory` : task definition memory (MUST be an int)
- `ecs_cluster_name` : defaults to `application_name` (not recommended to change)
- `ecs_service` : write entire service from scratch (not recommended - advanced users only)


See `default/vars/ecs.yml`. 
