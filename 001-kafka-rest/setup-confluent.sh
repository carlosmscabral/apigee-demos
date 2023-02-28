#!/bin/bash
sudo apt-get update && sudo apt-get install wget -y
sudo apt install default-jre -y
sudo apt install default-jdk -y
wget -qO - https://packages.confluent.io/deb/7.0/archive.key | sudo apt-key add -
echo "deb [arch=amd64] https://packages.confluent.io/deb/7.0 stable main" | sudo tee -a /etc/apt/sources.list
echo "deb https://packages.confluent.io/clients/deb $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update && sudo apt-get install confluent-platform -y
sudo chmod -R a+xwr /var/log/confluent
echo "delete.topic.enable=true" | sudo tee -a /etc/kafka/server.properties
sudo systemctl enable confluent-zookeeper; sudo systemctl start confluent-zookeeper
sudo systemctl enable confluent-server; sudo systemctl start confluent-server
sudo systemctl enable confluent-control-center; sudo systemctl start confluent-control-center
sudo systemctl enable confluent-kafka-rest; sudo systemctl start confluent-kafka-rest
