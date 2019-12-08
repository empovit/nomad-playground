data_dir = "/Users/<user>/nomad-data/client"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

# Change the ports so that they don't
# conflict with the server
ports {
  http = 5646
  rpc  = 5647
  serf = 5648
}