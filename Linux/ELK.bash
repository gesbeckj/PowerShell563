#!/bin/bash
apt update && apt -y upgrade
apt install apt-transport-https software-properties-common wget
add-apt-repository ppa:webupd8team/java
apt update
apt install oracle-java8-installer -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update &&  apt-get install elasticsearch
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
systemctl start elasticsearch.service
apt-get update && apt-get install kibana
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
systemctl start kibana.service
apt-get update && apt-get install logstash
