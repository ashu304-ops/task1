 Ansible Cluster in Docker & Kubernetes (Manual Setup - No Prebuilt Images)

This project sets up a basic Ansible automation cluster using  custom-built Docker containers and Kubernetes pods. 

---

##  Features

* Custom Docker image built from `ubuntu:20.04`
* Manual Ansible and SSH installation
* Passwordless SSH setup using SSH keys
* Compatible with both Docker and Kubernetes
* No prebuilt or preconfigured images used

---

## 📁 Project Structure

```
ansible-cluster/
│
├── Dockerfile             # Docker image with Ansible + SSH
├── inventory.ini          # Ansible inventory file
├── playbook.yml           # Sample Ansible playbook (optional)
├── kubernetes/
│   ├── ansible-master.yaml
│   ├── ansible-node1.yaml
│   └── ansible-node2.yaml
├── README.md              # This file
```

---

##  Docker Setup
 Create a dockerfile for  ansible node 
----------------------------------
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

-------------------------------------
### 1. Build the Docker Image

```
docker build -t ansible-node .
```

###  2. Create Network and Start Containers

```
docker network create ansible-net

docker run -dit --name ansible-master --network ansible-net ansible-node
docker run -dit --name ansible-node1 --network ansible-net ansible-node
docker run -dit --name ansible-node2 --network ansible-net ansible-node
```

### 🔑 3. Configure SSH Access (from Master)

Inside `ansible-master`:

```
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
sshpass -p root ssh-copy-id -o StrictHostKeyChecking=no root@ansible-node1
sshpass -p root ssh-copy-id -o StrictHostKeyChecking=no root@ansible-node2
```

### 4. Test Ansible Connection

Make inventory.ini

```
[node]
ansible-node1
ansible-node2
```

```
ansible all -m ping -i inventory.ini
```

---

## Kubernetes Setup

###  Push Image to DockerHub (or use local image in minikube/kind)

```
docker tag ansible-node your-dockerhub-username/ansible-node:latest
docker push your-dockerhub-username/ansible-node:latest
```

###  Deploy Pods

Edit and apply Kubernetes manifests in the `kubernetes/` folder:

```bash
kubectl apply -f kubernetes/ansible-master.yaml
kubectl apply -f kubernetes/ansible-node1.yaml
kubectl apply -f kubernetes/ansible-node2.yaml
```

### SSH Setup in Kubernetes

Use `kubectl exec` to access the Ansible master pod and repeat SSH keygen + `ssh-copy-id` steps using pod IPs from `kubectl get pods -o wide`.

---

## Sample Ansible Playbook (Optional)

```
# playbook.yml
- name: Ping all nodes
  hosts: all
  tasks:
    - name: Ping
      debug:
	
```

Run it:

```
ansible-playbook -i inventory.ini playbook.yml
```


















