#!/bin/bash

#Install NRPE
sudo apt-get update
sudo apt-get install -y autoconf automake gcc libc6 libmcrypt-dev make libssl-dev wget openssl
cd /tmp
wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.1.0.tar.gz
tar xzf nrpe.tar.gz
cd /tmp/nrpe-nrpe-4.1.0/
sudo ./configure --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/
sudo make all
sudo make install-groups-users
sudo make install
sudo make install-config
sudo sh -c "echo >> /etc/services"
sudo sh -c "sudo echo '# Nagios services' >> /etc/services"
sudo sh -c "sudo echo 'nrpe    5666/tcp' >> /etc/services"
sudo make install-init
sudo systemctl enable nrpe.service
sudo mkdir -p /etc/ufw/applications.d
sudo sh -c "echo '[NRPE]' > /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'title=Nagios Remote Plugin Executor' >> /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'description=Allows remote execution of Nagios plugins' >> /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'ports=5666/tcp' >> /etc/ufw/applications.d/nagios"
sudo ufw allow NRPE
sudo ufw reload
sudo sh -c "sed -i '/^allowed_hosts=/s/$/,192.168.1.164/' /usr/local/nagios/etc/nrpe.cfg"
sudo sh -c "sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg"
sudo systemctl start nrpe.service
sudo systemctl stop nrpe.service
sudo systemctl restart nrpe.service
sudo systemctl status nrpe.service

#Call NRPE plugins install
./scripts/nrpe_plugins.sh