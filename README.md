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

# Ansible Variables 

## Mandatory

### Common

Some variables are usually cross environment and should be placed in `infra/vars/main.yml`. 

- `application_name`: your application name (used for ELB, ASG, ECS, Task Definition naming)
- `aws_region`: aws region you're deploying to


### Environment specific

Some variables are always needed in `<env>/vars/main.yml`
- `aws_profile` : aws credentials profile to use at defined in `~/.aws/credentials`. It is heavily recommended not to use the `default` profile
- `aws_account_id` : https://portal.aws.amazon.com/gp/aws/manageYourAccount .
- `vpc_id` : vpc your application will live under
- `launch_config_key_name` : ssh key name for your ec2 instances (has to be an existing key)
- `environment_name` : e.g. development, test, production


## Optional overriding

All of the following variables already have a value, and should only be overriden if you require changing their default values. Look into the `default` directory to understand how the default are set.

To override a variable, just declare it in `infra/vars/main.yml` (if shared variables) or `<env>/vars/main.yml` (for environment specific). 

### ECS

The following optional variables are often overriden:
- `ecs_environment_variables` : list of environment variables to set (array of name / value)
- `ecs_port_mappings` : list of port mappings to set (array of containerPort / hostPort)
- `ecs_log_driver` : log driver to use to send log to specified location (e.g. splunk, syslog)
- `ecs_log_options` : options to provide based on `ecs_log_driver` value (see docker documentation)

The following optional variables are less often overriden:
- `ecs_taskdefinition_cpu` : task definition cpu (MUST be an int)
- `ecs_taskdefinition_memory` : task definition memory (MUST be an int)
- `ecs_cluster_name` : defaults to `application_name` (not recommended to change)
- `ecs_service` : write entire service from scratch (not recommended - advanced users only)

It is assumed that the images are deployed at `"{{ aws_account_id }}.dkr.ecr.{{ aws_region }}.amazonaws.com/{{ application_name }}:latest"`. If that's not the case, you can modify the environment variables below:
- `docker_image_repo` : location of repository to pull from
- `docker_image_name` : image name within the repo
- `docker_image_tag` : tag of the image

[See default/vars/ecs.yml](./ansible/roles/default/vars/ecs.yml)

### Autoscaling Group

To activate the creation of an ASG, place in `infra/vars/main.yml` the following:

- `create_auto_scaling_group: true`

The following variables are mandatory:

- `asg_subnets` : subnets for the auto-scaling group, under which your ec2 instances will be created. Reference more than one subnet to spawn across multiple availability zones. 

The following optional variables are available:

- `asg_additional_tags`: list of key value pairs that are applied as tags to your ec2 instances. 
- `asg_min_size` : minimum number of instances in your asg
- `asg_max_size` : max number of instances
- `asg_desired_capacity` : desired ASG capacity at launch
- `asg_override_desired_capacity` : force desired capacity (default false). Use true if you want to manually scale

- `launch_config_instance_size` : ec2 instance type
- `launch_config_instance_profile_name`: IAM instance profile name used to define EC2 instance permissions. 
- `launch_config_assign_public_ip` : boolean (true / false) to assign a public ip for ec2 instances

Application related: if user can access your application externally
- `application_port`: port that will be opened for your application
- `application_security_group_additional_open_ports`: additional list of ports (port / from) to add to security group

[See default/vars/asg.yml](./ansible/roles/default/vars/asg.yml)

### ELB

To activate the creation of an ELB, place in `infra/vars/main.yml` the following:

- `create_elb: true`
- `elb_inbound_ips`: array of authorized IPs for ELB inbound traffic rules. 
- `application_port`: your application port that the ELB will use to communicate with

The following variables can be optionally overriden:

- `elb_secure_https`: set to true if you'd like to authorize https traffic.
- `elb_ssl_certificate_name`: when `elb_secure_https` is set to true, you need to provide the ssl certificate name
- `elb_connection_draining_timeout` : see aws doc
- `elb_health_check_ping_path` : ping path to check app health
- `elb_health_check_response_timeout` : see aws doc
- `elb_health_check_interval` : see aws doc
- `elb_health_check_unhealthy_threshold` : see aws doc
- `elb_health_check_healthy_threshold` : see aws doc

[See default/vars/elb.yml](./ansible/roles/default/vars/elb.yml)

# EC2 Instances Shortcuts (alias and functions)

 - `dps`: shortcut for `docker ps`
 - `dl` : get the id of running docker container 
 - `dlog` : get the log of the running container
 - `dlogf` : get the tailing log of the running container
 - `dlogt` : get the log with timestamps of the running container
 - `dlog -ft` : get the log of the running container with tailing and timestamps
 - `dex <command>` : docker execute command (interactive mode) on the running container (ex: `dex bash`)

