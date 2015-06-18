#!/bin/bash
#clean
#systemctl stop haproxy && \
#systemctl stop zookeeper && \
#systemctl stop marathon && \
#systemctl stop mesos-master && \
#systemctl stop mesos-slave && \
#yum remove -y mesos marathon mesosphere-zookeeper haproxy

#optional
#yum groupinstall "Development Tools" –y

yum install -y net-tools && \
export local_ip=$(ifconfig eno16777736 | grep 'inet ' | awk '{ print $2}') && \
export master_node_ip="$local_ip" && \
export master_node_id="1" && \
export marathon_node_ip="$local_ip" && \
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm && \
rpm -Uvh http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm && \
setenforce Permissive && \
systemctl stop firewalld && \
systemctl disable firewalld && \
yum update -y && yum install -y bash curl wget tar zip unzip bzip2 telnet net-tools git ntp ntpdate && \
systemctl start ntpd && \
yum install -y mesos marathon mesosphere-zookeeper haproxy  && \
systemctl start haproxy && \
systemctl disable mesos-master && \
systemctl disable mesos-slave && \
systemctl disable marathon && \
systemctl disable zookeeper && \
echo "$master_node_id" > /var/lib/zookeeper/myid && \
echo "server.$master_node_id=$master_node_ip:2888:3888" >> /etc/zookeeper/conf/zoo.cfg &&\
echo "zk://$master_node_ip:2181/mesos" > /etc/mesos/zk && \
systemctl start zookeeper && \
mkdir -p /etc/marathon/conf && \
echo "1" > "/etc/mesos-master/quorum" && \
echo "$master_node_ip" > /etc/mesos-master/ip && \
echo "$master_node_ip" > /etc/mesos-master/hostname && \
cp /etc/mesos/zk /etc/marathon/conf/master && \
cp /etc/marathon/conf/master /etc/marathon/conf/zk && \
sed -i 's|mesos|marathon|g' /etc/marathon/conf/zk && \
systemctl start mesos-master && \
systemctl start marathon && \
cd /opt && wget "https://raw.githubusercontent.com/draculavlad/SetUpMesosphereOnCentos7WithServiceDiscovery/master/haproxy-marathon-bridge" && \
mkdir -p /etc/haproxy-marathon-bridge && \
echo "$marathon_node_ip:8080" > /etc/haproxy-marathon-bridge/marathons && \
chmod +x /opt/haproxy-marathon-bridge && \
cd /opt && ./haproxy-marathon-bridge install_cronjob 

echo "done......"
