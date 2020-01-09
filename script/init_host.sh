#!/bin/sh
set -eux
dir=$(cd $(dirname $0)/.. && pwd)
cd $dir

ip=$1
master_ip=$2

# update hostname
echo host-$ip > /etc/hostname
sed -i "s/127.0.0.1 .*/127.0.0.1 localhost host-$ip/g" /etc/hosts
sed -i "s/::1 .*/::1 localhost host-$ip/g" /etc/hosts
echo "$master_ip dc-registry" >> /etc/hosts
hostnamectl set-hostname host-$ip

# disable firewalld
systemctl disable --now firewalld

# clean iptables
bash $dir/script/clean_iptables.sh


# swap off
swapoff -a
sed -i "s/.*swap.*/#&/g" /etc/fstab

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# set net.bridge.bridge-nf-call-iptables
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
modprobe br_netfilter


cd $dir/package

# install docker
set +e
tar zxvf docker_ce_18_06_3.tar.gz
cd docker_ce_18_06_3
yum install -y *.rpm
mkdir -p /etc/docker
\cp $dir/config/daemon.json /etc/docker
systemctl enable --now docker
cd ..

# install kubeadm kubectl kubelet
set -e
tar zxvf kubeadm.tar.gz
mkdir -p /etc/systemd/system/kubelet.service.d
\cp kubeadm/kubeadm /usr/bin
\cp kubeadm/10-kubeadm.conf /etc/systemd/system/kubelet.service.d
tar zxvf kubelet.tar.gz
\cp kubelet/kubelet.service /usr/lib/systemd/system
\cp kubelet/kubelet /usr/bin
tar zxvf kubectl.tar.gz
\cp kubectl/kubectl /usr/bin
systemctl daemon-reload
systemctl enable --now kubelet
