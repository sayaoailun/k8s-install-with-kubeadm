#!/bin/sh

dir=$(cd $(dirname $0) && pwd)
# create admin
kubectl create -f $dir/admin-role.yaml
token=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-smartdc | head -1 | awk '{print $1}') | grep token: | sed "s/ //g" | sed "s/token://g")

getValue(){
    grep $1= $dir/config.txt|sed "s/$1=//g"
}
tag=$(getValue tag)
mysql_ip=$(getValue mysql_ip)
dc_image=dc-registry:5000/guojwe/dc:${tag}
mysql_image=dc-registry:5000/guojwe/mysql:5.7
# deploy mysql
mkdir -p $dir/mysql_data
docker run --name dc-mysql -p 3306:3306 --restart always -v $dir/mysql_data:/var/lib/mysql -e "TZ=Asia/Shanghai" -e LC_ALL=C.UTF-8 -e MYSQL_ROOT_PASSWORD=mysql -d $mysql_image --lower-case-table-names=1 --sql-mode="STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
while [[ ! 1 -eq `docker logs dc-mysql 2>&1|grep "Version"|grep 3306|wc -l` ]]; do
	sleep 3s
done
# init database
docker create --name dc-database $dc_image
docker cp dc-database:/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/db/mysql-init.sql $dir
docker rm dc-database
docker run -it --rm $mysql_image mysql -h$mysql_ip -uroot -pmysql < $dir/mysql-init.sql
# deploy dc
\cp $dir/dc.template.yaml $dir/dc.yaml
while read kv; do
    k=$(echo $kv|sed "s/=.*//g")
    v=$(echo $kv|sed "s/.*=//g")
    sed -i "s/\${$k}/$v/g" $dir/dc.yaml
done < $dir/config.txt
kubectl create -f $dir/dc.yaml