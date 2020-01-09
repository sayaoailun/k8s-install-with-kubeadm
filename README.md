# 部署k8s
## 脚本说明
- [install.sh](script/install.sh): 部署k8s的master和worker节点
- [install_master.sh](script/install_master.sh): 部署k8s的master节点
- [install_worker.sh](script/install_worker.sh): 部署k8s的worker节点

## 配置说明
### [config.txt](config/config.txt)
- master_ip: master节点的IP
- rootPassword: worker节点的root用户密码
- data_path: worker节点的数据目录

### [hostips.txt](config/hostips.txt)
- worker节点的IP列表
- 每行一个IP，**文件以换行符结束**

## 部署说明
``` shell
# 修改config.txt和hostips.txt文件后执行
bash script/install.sh
```

# 部署Sm@rtDC

**部署好k8s后方可部署Sm@rtDC**

- [config.txt](smartdc/config.txt): 修改为实际环境的配置，每行一个配置，**文件以换行符结束**
- [deploy_dc.sh](smartdc/deploy_dc.sh): 部署Sm@rtDC的脚本

``` shell
# 修改config.txt文件后执行
bash smartdc/deploy_dc.sh
```
