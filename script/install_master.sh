#!/bin/sh
set -eux

dir=$(cd $(dirname $0)/.. && pwd)
cd $dir/script

getValue(){
    grep $1= $dir/config/config.txt|sed "s/$1=//g"
}

master_ip=$(getValue master_ip)
# init_host
bash init_host.sh $master_ip $master_ip

# deploy registry
bash deploy_registry.sh

# deploy k8s
bash deploy_k8s.sh $master_ip