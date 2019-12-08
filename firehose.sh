#!/bin/bash

# Starts an instance of Nomad Firehose that 
# monitors a Nomad '<endpoint>'' and publishes 
# the events to 'nomad' AMQP exchange with a 
# routing key 'nomad-<endpoint>'.

# Usage: ./firehose.sh <endpoint>
# Example: ./firehose.sh allocations

export NOMAD_ADDR=http://localhost:4646
export SINK_TYPE=amqp
export SINK_AMQP_CONNECTION=amqp://guest:guest@127.0.0.1:5672/
export SINK_AMQP_WORKERS=1 # what’s this?
export SINK_AMQP_ROUTING_KEY=nomad-$1
export SINK_AMQP_EXCHANGE=nomad

nomad-firehose $1