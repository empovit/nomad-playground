#!/bin/sh

for q in $(docker exec -ti rabbitmq rabbitmqadmin list queues --format=bash | tr -d '\r')
do
    echo "Queue: $q"
    docker exec -ti rabbitmq rabbitmqadmin purge queue name=$q
done