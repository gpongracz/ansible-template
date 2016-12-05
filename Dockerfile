FROM python:2.7.12

RUN apt-get update && apt-get install -y nano

ENV EDITOR=nano

ARG ANSIBLE_COMMIT_HASH=8e375913b0e80137e3449e7af40ee4c7eba6f121
RUN pip install git+https://github.com/ansible/ansible.git@$ANSIBLE_COMMIT_HASH#egg=ansible boto boto3

VOLUME ["/project", "/root/.aws"]
WORKDIR /project