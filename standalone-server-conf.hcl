data_dir = "/tmp/nomad-server"
disable_update_check = true

server {

  enabled = true

  # Do not waith for other servers to join the cluster
  bootstrap_expect = 1

  server_join {
    retry_join = []
  }
}