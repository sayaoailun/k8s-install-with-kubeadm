#!/bin/sh
set -exu
dir=$(cd $(dirname $0)/.. && pwd)
# install sshpass
yum install -y $dir/package/sshpass-1.05-5.ns7_4.mips64el.rpm

# install master
bash $dir/script/install_master.sh

# install worker
getValue(){
    grep $1= $dir/config/config.txt|sed "s/$1=//g"
}
master_ip=$(getValue master_ip)
rootPassword=$(getValue rootPassword)
data_path=$(getValue data_path)/k8s_install
while read ip; do
    sshpass -p$rootPassword ssh root@$ip mkdir -p $data_path
    sshpass -p$rootPassword scp -r $dir/config root@$ip:$data_path
    sshpass -p$rootPassword scp -r $dir/package root@$ip:$data_path
    sshpass -p$rootPassword scp -r $dir/script root@$ip:$data_path
    sshpass -p$rootPassword ssh root@$ip bash $data_path/script/install_worker.sh $ip $master_ip
done < $dir/config/hostips.txt