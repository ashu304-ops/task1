FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Ansible and SSH
RUN apt-get update && \
    apt-get install -y python3 python3-pip openssh-server sshpass sudo && \
    pip3 install ansible && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/Port 22/Port 22/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]