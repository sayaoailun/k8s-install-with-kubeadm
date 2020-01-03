#!/bin/sh
set -eux
dir=$(cd $(dirname $0)/.. && pwd)
mkdir -p $dir/data
tar zxvf $dir/registry/registry_data.tar.gz -C $dir/data
registry_data=$dir/data/registry
docker load -i $dir/registry/registry_image.tar
docker run --name dc-registry --restart always -d -p 5000:5000 -v $registry_data:/var/lib/registry -e REGISTRY_STORAGE_DELETE_ENABLED=true -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true dc-registry:5000/guojwe/registry:1