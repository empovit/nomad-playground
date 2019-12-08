#!/bin/bash

# Prints messages accumulated in a RabbitMQ queue on localhost.
# The queue must have a name in the format 'nomad-<endpoint>'
# Requires python3.

# Usage: ./print_messages.sh <endpoint>
# Example: ./print_messages.sh allocations

curl http://localhost:15672/api/queues/%2F/nomad-$1/get -H "Content-Type: application/json" \
    -d "{\"vhost\":\"/\",\"name\":\"nomad-$1\",\"truncate\":\"50000\",\"ackmode\":\"ack_requeue_true\",\"encoding\":\"auto\",\"count\":\"100\"}" \
    -f -u guest:guest | python3 rabbit2json.py