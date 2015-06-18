#!/bin/bash

export master_node_ip=
export local_ip=$(ifconfig eno16777736 | grep 'inet ' | awk '{ print $2}')
export slave_node_ip="$local_ip"

rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm && \
rpm -Uvh http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm && \
setenforce Permissive && \
systemctl stop firewalld && \
systemctl disable firewalld && \
yum update -y && yum install -y bash curl wget tar zip unzip bzip2 telnet net-tools git ntp ntpdate && \
systemctl start ntpd && \
yum install -y mesos marathon mesosphere-zookeeper  && \
systemctl disable mesos-master && \
systemctl disable mesos-slave && \
systemctl disable marathon && \
systemctl disable zookeeper && \
echo "zk://$master_node_ip:2181/mesos" > /etc/mesos/zk && \
echo "$slave_node_ip" > "/etc/mesos-slave/ip" && \
echo "$slave_node_ip" > "/etc/mesos-slave/hostname" && \
echo 'docker,mesos' > /etc/mesos-slave/containerizers && \
echo '5mins' > /etc/mesos-slave/executor_registration_timeout && \
systemctl start mesos-slave
