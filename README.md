# SetUpMesosphereOnCentos7 with Service Discovery
Set up a dockerized mesosphere cluster with CentOS 7 with service discovery using haproxy following the official document and a little designated operation for centos 7 and haproxy 1.5. I modified the file from the link [https://raw.githubusercontent.com/mesosphere/marathon/master/bin/haproxy-marathon-bridge] to make the configuration work well with haproxy 1.5
My mail: 450416583@qq.com, jacobsuyu@gmail.com

## References
* https://www.youtube.com/watch?v=hZNGST2vIds&feature=youtu.be
* https://open.mesosphere.com/getting-started/datacenter/install/
* http://open.mesosphere.com/getting-started/service-discovery/

## a little setup for my instance 
```shell
    yum update -y && yum install bash curl wget tar zip unzip bzip2 telnet net-tools git -y && yum groupinstall "Development Tools" –y
    yum -y install ntp ntpdate
    systemctl start ntpd
```

## disable firewalld & selinux if needed
```shell
    setenforce Permissive
    systemctl stop firewalld
    systemctl disable firewalld
```

## add yum repo
```shell
    rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
    rpm -Uvh http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm
```

## installation 
```shell
    yum -y install mesos marathon mesosphere-zookeeper haproxy
```

## start haproxy
```shell
    systemctl start haproxy
```

## pre-configuration
```shell
    systemctl disable mesos-master
    systemctl disable mesos-slave
    systemctl disable marathon
    systemctl disable zookeeper
```

## zookeeper configuration (master node only)
- set [file:/var/lib/zookeeper/myid] with a unique master_node_id(1-255)
- append all master node information to [file:/etc/zookeeper/conf/zoo.cfg] with format like: "server.$master_node_id=$master_node_ip:2888:3888"

## zookeeper start (master node only)
```shell
    systemctl start zookeeper
```

## mesos configuration (for both master & slave node)
- set [file:/etc/mesos/zk] to  "zk://$first_master_node_ip:2181,$second_master_node_ip:2181,.../mesos" 

## mesos master && marathon configuration (master node only)
```shell
    mkdir -p /etc/marathon/conf
```
- set [file:/etc/mesos-master/quorum] to a number which shoud be greater than half the total number of your master nodes 
- set [file:/etc/mesos-master/ip] to your master node ip address
- set [file:/etc/mesos-master/hostname] to your master node domain name which required to be resolvable by your other mesos nodes
```shell
    cp /etc/mesos/zk /etc/marathon/conf/master
    cp /etc/marathon/conf/master /etc/marathon/conf/zk
    sed –i 's|mesos|marathon|g' /etc/marathon/conf/zk
```
## enable mesos master service discovery (master node only)
```shell
    wget https://github.com/draculavlad/SetUpMesosphereOnCentos7/blob/master/haproxy-marathon-bridge
```
- set [file:/etc/haproxy-marathon-bridge/marathons] to a list of your marathon nodes:
```shell
    echo "$first_marathon_node_ip:8080" >> /etc/haproxy-marathon-bridge/marathons
    echo "$second_marathon_node_ip:8080" >> /etc/haproxy-marathon-bridge/marathons
    echo "$third_marathon_node_ip:8080" >> /etc/haproxy-marathon-bridge/marathons
```
```shell
    chmod +x haproxy-marathon-bridge
    ./haproxy-marathon-bridge install_cronjob
```
## start mesos master (master node only)
```shell
    systemctl start mesos-master
```
## start marathon (master node only)
```shell
    systemctl start marathon
```
## mesos slave configuration (slave node only)
- set [file:/etc/mesos-slave/ip] to your slave node ip address
- set [file:/etc/mesos-slave/hostname] to your slave node domain name which required to be resolvable by your other mesos nodes
```shell
    echo 'docker,mesos' > /etc/mesos-slave/containerizers
    echo '5mins' > /etc/mesos-slave/executor_registration_timeout
```
## start mesos slave (slave node only)
```shell
    systemctl start mesos-slave
```
- test script is referenced to https://www.youtube.com/watch?v=hZNGST2vIds&feature=youtu.be
```shell
    wget https://github.com/draculavlad/SetUpMesosphereOnCentos7WithServiceDiscovery/blob/master/launch.sh
    wget https://github.com/draculavlad/SetUpMesosphereOnCentos7WithServiceDiscovery/blob/master/nginx-bridge.json
    export marathon_node_ip=$your_marathon_node_ip
    chmod +x launch.sh
    ./launch.sh nginx-bridge.json
```
