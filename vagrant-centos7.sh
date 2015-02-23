##!/bin/bash

#Identify network interface
ifc=`ls /etc/sysconfig/network-scripts/ifcfg-* | grep -v '\ifcfg-lo'`

#Backup network config
cp $ifc $ifc.bak

#Edit network config
sed -i "s/ONBOOT=no/ONBOOT=yes/" "$ifc"
sed -i "/^HARDW/d" "$ifc"

#Restart networking
service network restart

#Update and Upgrade
yum update -y && yum upgrade -y

#Install required apps
yum install -y openssh-server ntp git gcc kernel-devel wget bzip2

#Enable ntp and ssh
systemctl enable sshd.service && systemctl enable ntpd.service

#Disable iptables (Not required for vagrant test)
systemctl disable iptables.service && systemctl disable ip6tables.service

#Change Selinux to Permissive
sed -i "s/^SELINUX=.*/SELINUX=permissive/" /etc/selinux/config

#Create vagrant user and set password
useradd -m vagrant && echo vagrant | passwd vagrant --stdin

#Add vagrant to sudoers and remove requiretty
sed -i "s/^\(Defaults.*requiretty\)/#\1/" /etc/sudoers && echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Creare SSH directory and place vagrant keys
mkdir /home/vagrant.ssh && curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys

#Change SSH directory owner and permissions
chmod 600 /homs/vagrant/.ssh/autorized_keys && chown -R vagrant:vagrant /home/vagrant/.ssh

#Cleanup
rm -rf /tmp/* && rm -f /var/log
yum clean all && history -c

#Shutdown
shutdown -h now