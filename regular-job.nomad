job "sleep-2min" {

  datacenters = ["dc1"]
  
  type = "batch"

  group "sleep-test" {

    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "sleep-task" {
      driver = "docker"
      config {
        image = "sleep-job:1"
      }

      env {
        TIME = "120"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 64 # 256MB
      }
    }
  }
}