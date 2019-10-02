data_dir = "/Users/<user>/Documents/nomad/data"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

ports {
  http = 5646
  rpc  = 5647
  serf = 5648
}