# docker-ubuntu-ansible

[![Build Status](https://travis-ci.org/djx339/docker-ubuntu-ansible.svg?branch=master)](https://travis-ci.org/djx339/docker-ubuntu-ansible)

Ubuntu Docker image for Ansible playbook and role testing.

## Usage

```shell
# for 14.04
docker run --name ansible_ubuntu_init djx339/ubuntu-ansible:14.04

# for 16.04
docker run --name ansible_ubuntu_init -itd --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro djx339/ubuntu-ansible:16.04
```
