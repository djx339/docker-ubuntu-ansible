#!/bin/bash
#
# Ansible role test shim.
#
# Usage: [OPTIONS] ./tests/test.sh
#   - distro: a supported Docker distro version (default = "centos7")
#   - playbook: a playbook in the tests directory (default = "test.yml")
#   - cleanup: whether to remove the Docker container (default = true)
#   - container_id: the --name to set for the container (default = timestamp)

# Exit on any individual command failure.
set -e

# Pretty colors.
red='\033[0;31m'
green='\033[0;32m'
neutral='\033[0m'

timestamp=$(date +%s)

# Allow environment variables to override defaults.
distro=${distro:-"ubuntu1404"}
playbook=${playbook:-"test.yml"}
cleanup=${cleanup:-"true"}
container_id=${container_id:-$timestamp}
playbook_opts=${playbook_opts:-""}

## Set up vars for Docker setup.
# CentOS 7
if [ $distro = 'centos7' ]; then
  image="djx339/centos-ansible:7-systemd"
  opts="--privileged --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro"
# CentOS 6
elif [ $distro = 'centos6' ]; then
  image="djx339/centos-ansible:6"
  opts="--privileged"
# Ubuntu 16.04
elif [ $distro = 'ubuntu1604' ]; then
  image="djx339/ubuntu-ansible:16.04"
  opts="--privileged --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro"
# Ubuntu 14.04
elif [ $distro = 'ubuntu1404' ]; then
  image="djx339/ubuntu-ansible:14.04"
  opts="--privileged"
# Ubuntu 12.04
elif [ $distro = 'ubuntu1204' ]; then
  image="djx339/ubuntu-ansible:12.04"
  opts="--privileged"
# Debian 8
elif [ $distro = 'debian8' ]; then
  image="djx339/debian-ansible:8"
  opts="--privileged"
# Fedora 24
elif [ $distro = 'fedora24' ]; then
  image="djx339/fedora-ansible:24"
  opts="--privileged"
fi

# Run the container using the supplied OS.
printf ${green}"Starting Docker container: ${image}."${neutral}"\n"
docker pull ${image}
docker run -itd --volume="$PWD":/etc/ansible/roles/role_under_test:rw --name $container_id $opts ${image}

printf "\n"

# Install requirements if `requirements.yml` is present.
if [ -f "$PWD/tests/requirements.yml" ]; then
  printf ${green}"Requirements file detected; installing dependencies."${neutral}"\n"
  docker exec --tty $container_id env TERM=xterm ansible-galaxy install -r /etc/ansible/roles/role_under_test/tests/requirements.yml
fi

printf "\n"

# Test Ansible syntax.
printf ${green}"Checking Ansible playbook syntax."${neutral}
docker exec --tty $container_id env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook --syntax-check

printf "\n"

# Run Ansible playbook.
printf ${green}"Running command: docker exec $container_id env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook"${neutral}
docker exec $container_id env TERM=xterm env ANSIBLE_FORCE_COLOR=1 ansible-playbook $playbook_opts /etc/ansible/roles/role_under_test/tests/$playbook

# Run Ansible playbook again (idempotence test).
printf ${green}"Running playbook again: idempotence test"${neutral}
idempotence=$(mktemp)
docker exec $container_id ansible-playbook $playbook_opts /etc/ansible/roles/role_under_test/tests/$playbook | tee -a $idempotence
tail $idempotence \
  | grep -q 'changed=0.*failed=0' \
  && (printf ${green}'Idempotence test: pass'${neutral}"\n") \
  || (printf ${red}'Idempotence test: fail'${neutral}"\n" && exit 1)

# Remove the Docker container (if configured).
if [ "$cleanup" = true ]; then
  printf "Removing Docker container...\n"
  docker rm -f $container_id
fi
