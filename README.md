# Getting Started

This template is supposed to live inside a deployable or infrastructure project and can self-update.
To download and bootstrap a new template instance :

```
curl -L https://github.com/simple-machines/ansible-template/archive/master.tar.gz | tar zxv
mv ansible-template-master ansible
cd ansible
echo "12345" > .vaultpassword
./build.sh 
```

## Running

Requires Docker to be installed.
The image is hosted on DockerHub

Install by executing the following command :

 ```
 ./build.sh
 ```

## Running playbooks after configuration
```
./run-playbook.sh dev.yml
./run-playbook.sh prod.yml
```

## Adding password file and edit the secret variables

```
echo "12345">.vaultpassword
./editvault.sh dev
./editvault.sh prod
```

# Configuration - Ansible Variables

infra vs env explanation

## Global Variables

| variable name          | default | env/infra guidance | importance | description                                                                                             |
|------------------------|---------|-----------|------------|---------------------------------------------------------------------------------------------------------|
| application_name       | my-app  | infra     | mandatory  | Your application name. Letters (uppercase and lowercase), numbers, hyphens, and underscores are allowed |
| aws_region             |         | env       | mandatory  | Region where you application will be deployed                                                           |
| aws_profile            |         | env       | mandatory  | aws profile to use for deployment (in ~/.aws/credentials)                                               |
| vpc_id                 |         | env       | mandatory  | vpc the application will be deployed in                                                                 |
| launch_config_key_name |         | env       | mandatory  | ssh key name for your ec2 instances (existing key)                                                      |


## ECS

### Service / Task Definition

| variable name             | default                                                     | env/infra guidance                                     | importance | description                                                                                                                                                                                   |
|---------------------------|-------------------------------------------------------------|--------------------------------------------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ecs_environment_variables | []                                                          | define structure in infra, replace env specific in env | high       | Use this variable if your application requires environment variables                                                                                                                          |
| ecs_additional_port_mappings         | []                                                          | infra                                                  | high       | **Application port is opened by default**. Array of extra port mappings to set (containerPort / hostPort). e.g. ecs_additional_port_mappings:  - containerPort: 9999    hostPort: 9999                                                                        |
| ecs_volume |  | infra | medium | optional volume to mount. provide two keys from and to, e.g. "from": "/mnt", "to": "/etc"
| ecs_service_desired_count |  asg_desired_capacity (1) | infra | medium | Manually set how many tasks you desire. Will default to the desired capacity of your asg by default
| ecs_log_driver            | json-file                                                   | env                                                    | low        | log options (replace this variable if you want to send logs to external aggregators e.g. splunk)                                                                                              |
| ecs_taskdefinition_cpu    | max it can use for the instance                             |                                                        | low        | the cpu for the task definition. By default utilise all available                                                                                                                             |
| ecs_taskdefinition_memory | max it can use for the instance                             |                                                        | low        | the memory for the task definition. By default utilise all available                                                                                                                          |
| ecs_cluster_name          | application_name                                            |                                                        | very low   | your ecs cluster name is your application name                                                                                                                                                |
| ecs_service               | complex                                                     |                                                        | very low   | advanced users only. Do not override unless you know what you're doing.                                                                                                                       |

### Docker image

The AWS account ID where the docker images are stored (ECR). See docker_image_repo. Images are expected to be found at `"{{ docker_image_repo }}/{{ application_name }}:{{ docker_image_tag }}"`.


| variable name             | default                                                     | env/infra guidance                                     | importance | description                                                                                                                                                                                   |
|---------------------------|-------------------------------------------------------------|--------------------------------------------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| aws_account_id            |                                                             | env                                                    | mandatory  | The AWS account ID where the docker images are stored (ECR). See docker_image_repo. Images is expected to be found at "{{ docker_image_repo }}/{{ application_name }}:{{ docker_image_tag }}" |
| docker_image_repo         | {{ aws_account_id }}.dkr.ecr.{{ aws_region }}.amazonaws.com | env                                                    | low        | repository host name where images are stored                                                                                                                                                  |
| docker_image_name         | {{ application_name }}                                      | infra                                                  | low        | image name to look for                                                                                                                                                                        |
| docker_image_tag          | latest                                                      | env                                                    | medium     | image tag. Change this if you need to use a specific version instead of latest                                                                                                                |


## Autoscaling Group

To activate the creation of an ASG, place in `infra/vars/main.yml` the following:

- `create_auto_scaling_group: true`

| variable name                                    | default  | env/infra guidance                             | importance | description                                                                                                                                  |
|--------------------------------------------------|----------|------------------------------------------------|------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| asg_subnets                                      | []       | env                                            | mandatory  | List of subnets to deploy the application to                                                                                                 |
| asg_additional_tags                              | [{"Name":"{{ application_name }}"}]       | common structure in infra, env specific in env | high       | List of tags to apply to your asg and its ec2 instances                                                                                      |
| asg_min_size                                     | 1        | env                                            | medium     | minimum number of ec2 instances in your asg                                                                                                  |
| asg_max_size                                     | 1        | env                                            | medium     | maximum number of ec2 instances in your asg                                                                                                  |
| asg_desired_capacity                             | 1        | env                                            | medium     | desired number of ec2 instances in your asg                                                                                                  |
| asg_override_desired_capacity                    | false    | env                                            | high       | if false, asg_desired_capacity will be ignored if an asg already exists. if true, the asg will scale in or out to match asg_desired_capacity |
| launch_config_instance_size                      | t2.small | env                                            | high       | ec2 instance size                                                                                                                            |
| launch_config_instance_profile_name              |          | env                                            | high       | IAM instance profile name to define EC2 instances permissions                                                                                |
| launch_config_assign_public_ip                   | false    | env                                            | medium     | true means a public IP will be assigned to every new instance                                                                                |
| application_port                                 |  9000    | infra                                          | high       | port that will be opened for your application                                                                                                |
| application_security_group_additional_open_ports | []       | infra                                          | medium     | list of ports (from / port) to add to the security group                                                                                     |
| additional_user_data_bootcmd | dummy echo commands (see default/main.yml) | infra | medium | multiline string that start by hyphens (-)


## ELB

To activate the creation of an ELB, place in `infra/vars/main.yml` the following:

- `create_elb: true`

| variable name                        | default | env/infra guidance | importance | description                                                                                                  |
|--------------------------------------|---------|--------------------|------------|--------------------------------------------------------------------------------------------------------------|
| elb_inbound_ips                      |         | env                | mandatory  | array of authorized IPs for ELB inbound traffic rules                                                        |
| application_port                     | 9000    | infra              | mandatory  | The application port that the ELB will talk to                                                               |
| elb_secure_https                     | false   | env                | high       | set to true if you'd like to authorise https traffic.                                                        |
| elb_ssl_certificate_name             |         | env                | high       | if elb_secure_https is set to true, you need to provide the ssl certificate name                             |
| elb_health_check_ping_path           | /       | infra              | high       | ping path for health checks (your application need to have a health check route that returns 200 if healthy) |
| elb_connection_draining_timeout      | 60      | infra              | medium     | see aws doc                                                                                                  |
| elb_health_check_response_timeout    | 5       | infra              | medium     | see aws doc                                                                                                  |
| elb_health_check_interval            | 15      | infra              | medium     | see aws doc                                                                                                  |
| elb_health_check_unhealthy_threshold | 6       | infra              | medium     | see aws doc                                                                                                  |
| elb_health_check_healthy_threshold   | 2       | infra              | medium     | see aws doc                                                                                                  |

# EC2 Instances Shortcuts (alias and functions)

 - `dps`: shortcut for `docker ps`
 - `dl` : get the id of running docker container
 - `dlog` : get the log of the running container
 - `dlogf` : get the tailing log of the running container
 - `dlogt` : get the log with timestamps of the running container
 - `dlog -ft` : get the log of the running container with tailing and timestamps
 - `dex <command>` : docker execute command (interactive mode) on the running container (ex: `dex bash`)



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
