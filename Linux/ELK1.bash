#Elasticsearch
sudo apt update && apt -y upgrade
sudo apt install apt-transport-https software-properties-common wget
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add
sudo apt-get update && sudo apt-get install elasticsearch
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo sed -i 's/#START_DAEMON/START_DAEMON/' /etc/default/elasticsearch
sudo systemctl restart elasticsearch
systemctl status elasticsearch
#Kibana
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add
sudo apt-get update && sudo apt-get install kibana
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/i' /etc/kibana/kibana.yml
sudo systemctl restart kibana.service
#Logstash
sudo apt-get update && apt-get install logstash
sudo systemctl start logstash.service


sudo /usr/share/logstash/bin/logstash-plugin install logstash-input-lumberjack