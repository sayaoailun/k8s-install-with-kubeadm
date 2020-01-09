#!/bin/sh

set -eux

dir=$(cd $(dirname $0)/.. && pwd)
cd $dir
master_ip=$1

sed -i "s/name: .*/name: $(hostname)/g" $dir/yaml/k8s.yaml
sed -i "s/advertiseAddress: .*/advertiseAddress: $master_ip/g" $dir/yaml/k8s.yaml
source $dir/script/unset_proxy.sh
kubeadm init --config=$dir/yaml/k8s.yaml
mkdir -p $HOME/.kube
\cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f $dir/yaml/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
tar zxvf $dir/yaml/metrics-server.tar.gz -C $dir/yaml
kubectl apply -f $dir/yaml/metrics-server
kubectl apply -f $dir/yaml/ingress-mandatory.yaml
tar zxvf $dir/yaml/nfs-provisioner.tar.gz -C $dir/yaml
mkdir -p $dir/data/nfs
sed -i "s#path: .*#path: $dir/data/nfs#g" $dir/yaml/nfs-provisioner/deployment.yaml
kubectl apply -f $dir/yaml/nfs-provisioner/rbac.yaml
kubectl apply -f $dir/yaml/nfs-provisioner/deployment.yaml
kubectl apply -f $dir/yaml/nfs-provisioner/class.yaml
tar zxvf $dir/yaml/prometheus.tar.gz -C $dir/yaml
kubectl create namespace monitoring
kubectl apply -f $dir/yaml/prometheus

while :
do
    sleep 3s
    if [[ -e /var/lib/kubelet/config.yaml ]]; then
        sed -i "s/mode: .*/mode: AlwaysAllow/g" /var/lib/kubelet/config.yaml
        systemctl restart kubelet
        break
    fi
done

\cp /etc/kubernetes/admin.conf $dir/config
\cp /etc/kubernetes/pki/ca.crt $dir/config
