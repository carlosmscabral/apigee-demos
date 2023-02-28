#!/bin/bash

# only for reference. Mostly based on https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-debian-10

kafka-topics --create --topic priority --bootstrap-server=localhost:9092 \
 --partitions 1 --replication-factor 1

kafka-topics --create --topic no-priority --bootstrap-server=localhost:9092 \
 --partitions 1 --replication-factor 1

kafka-topics --list --bootstrap-server=localhost:9092

kafka-topics --describe --topic priority --bootstrap-server=localhost:9092

echo '{"id":34}' | kafka-console-producer --bootstrap-server=localhost:9092 --topic priority

kafka-console-consumer --bootstrap-server=localhost:9092 --topic priority --from-beginning

kafka-topics --delete --topic priority --bootstrap-server=localhost:9092
kafka-topics --delete --topic no-priority --bootstrap-server=localhost:9092