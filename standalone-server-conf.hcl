data_dir = "/Users/<user>/Documents/nomad/data"

server {

  enabled          = true
  bootstrap_expect = 1

  server_join {
    retry_join = []
  }
}