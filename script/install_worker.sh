#!/bin/sh
set -eux

dir=$(cd $(dirname $0)/.. && pwd)

getValue(){
    grep $1= $dir/config/config.txt|sed "s/$1=//g"
}

master_ip=$(getValue master_ip)
ip=$1
# init_host
bash $dir/script/init_host.sh $ip $master_ip

# join k8s
mkdir -p $HOME/.kube
\cp $dir/config/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
k8s_token=$(kubeadm token create)
ca_cert_hash=$(openssl x509 -pubkey -in $dir/config/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
source $dir/script/unset_proxy.sh
kubeadm join $master_ip:6443 --token $k8s_token --discovery-token-ca-cert-hash sha256:$ca_cert_hash
while :
do
    sleep 3s
    if [[ -e /var/lib/kubelet/config.yaml ]]; then
        sed -i "s/mode: .*/mode: AlwaysAllow/g" /var/lib/kubelet/config.yaml
        systemctl restart kubelet
        break
    fi
done

