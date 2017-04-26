FROM ubuntu:14.04
MAINTAINER Daniel D <djx339@gmail.com>
ENV container docker
# much of this was gleaned from https://github.com/lxc/lxc/blob/lxc-0.8.0/templates/lxc-ubuntu.in
# and then heavily modified and hacked like crazy

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        openssh-server \
        sudo \
        wget \
    && rm -rf /var/lib/apt/lists/*

ADD init-fake.conf /etc/init/fake-container-events.conf

# undo some leet hax of the base image
RUN rm /usr/sbin/policy-rc.d; \
	rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl

# generate a nice UTF-8 locale for our use
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
	for f in \
		/etc/init/u*.conf \
		/etc/init/mounted-dev.conf \
		/etc/init/mounted-proc.conf \
		/etc/init/mounted-run.conf \
		/etc/init/mounted-tmp.conf \
		/etc/init/mounted-var.conf \
		/etc/init/hostname.conf \
		/etc/init/networking.conf \
		/etc/init/tty*.conf \
		/etc/init/plymouth*.conf \
		/etc/init/hwclock*.conf \
		/etc/init/module*.conf\
	; do \
		dpkg-divert --local --rename --add "$f"; \
	done; \
	echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab

# small fix for SSH in 13.10 (that's harmless everywhere else)
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# set a cheap, simple password for great convenience
RUN echo 'root:docker.io' | chpasswd

# add a trusted ssh key
RUN mkdir -p /root/.ssh/ \
    && curl -skLo /root/.ssh/authorized_keys https://raw.githubusercontent.com/djx339/docker-ubuntu-ansible/master/ansible_docker.key.pub \
    && chmod 700 /root/.ssh \
    && chmod 640 /root/.ssh/authorized_keys

RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
    && apt-add-repository -y ppa:ansible/ansible \
    && apt-get update \
    && apt-get install -y ansible python-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip install jmespath

# Install Ansible inventory file.
RUN echo '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# we can has SSH
EXPOSE 22

# pepare for takeoff
CMD ["/sbin/init"]
