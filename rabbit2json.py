#!/usr/bin/env python3

# Prints messages received via stdin (e.g. pipe)
# in the format of RabbitMQ Queue API as JSON, 
# along with the count and size of each message.

import sys
import json

data = sys.stdin.read()

for m in json.loads(data):
    payload = json.loads(m['payload'])
    count = m['message_count']
    size = m['payload_bytes']
    print(f"=== Message #{count} ({size} bytes) ===")
    print(json.dumps(payload, indent=4))