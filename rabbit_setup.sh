#!/bin/sh

# Declares a RabbitMQ exchange 'nomad', a queue 'nomad-<endpoint>',
# and binds the queue to the exchange with routing key 'nomad-<endpoint>'.
# Will work even if the exchange or queue already exits.

# Requires an instance of RabbitMQ running inside 
# a Docker container named 'rabbitmq'.

# Usage: ./rabbit_setup.sh <endpoint>
# Example: ./rabbit_setup.sh allocations

docker exec -ti rabbitmq rabbitmqadmin declare queue name=nomad-$1 auto_delete=false durable=true
docker exec -ti rabbitmq rabbitmqadmin declare exchange name=nomad type=direct auto_delete=false durable=true
docker exec -ti rabbitmq rabbitmqadmin declare binding source=nomad destination=nomad-$1 routing_key=nomad-$1