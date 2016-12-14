FROM python:2.7.12

RUN apt-get update && apt-get install -y nano

ENV EDITOR=nano

ARG ANSIBLE_COMMIT_HASH=f28b5a0ed86d9b007744b7815cb2ca4a283275f4
RUN pip install git+https://github.com/ansible/ansible.git@$ANSIBLE_COMMIT_HASH#egg=ansible boto boto3
RUN pip install awscli

VOLUME ["/project", "/root/.aws"]
WORKDIR /project
