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
