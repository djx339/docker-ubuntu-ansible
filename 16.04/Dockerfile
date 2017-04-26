FROM ubuntu:16.04
MAINTAINER Daniel D <djx339@gmail.com>
ENV container docker


# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
         /lib/systemd/system \
         -path '*.wants/*' \
         -not -name '*journald*' \
         -not -name '*systemd-tmpfiles*' \
         -not -name '*systemd-user-sessions*' \
         -exec rm \{} \;

RUN systemctl set-default multi-user.target

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        openssh-server \
        sudo \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# set a cheap, simple password for great convenience
RUN echo 'root:docker.io' | chpasswd

# add a trusted ssh key
RUN mkdir -p /root/.ssh/ \
    && curl -skLo /root/.ssh/authorized_keys https://raw.githubusercontent.com/djx339/docker-ubuntu-ansible/master/ansible_docker.key.pub \
    && chmod 700 /root/.ssh \
    && chmod 640 /root/.ssh/authorized_keys

COPY setup /sbin/

STOPSIGNAL SIGRTMIN+3

RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
    && apt-add-repository -y ppa:ansible/ansible \
    && apt-get update \
    && apt-get install -y ansible python-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip install jmespath

# Install Ansible inventory file.
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# we can has SSH
EXPOSE 22

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
