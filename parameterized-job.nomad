# Register parametrized job:
# > nomad run parameterized-job.nomad
#
# Run job with default values:
# > nomad job dispatch sleep
#
# Run job with an argument:
# > nomad job dispatch -meta TIME=360 sleep
#
# Monitor the job:
# > curl -v "http://127.0.0.1:4646/v1/jobs?index=XXX"

job "sleep" {
  
  datacenters = ["dc1"]

  type = "batch"

  parameterized {
    payload       = "forbidden"
    meta_optional = ["TIME"]
  }

  group "sleep-group" {

    task "sleep-task" {

      driver = "docker"
      
      config {
        image = "sleep-job:1"
      }

      env {
        TIME = "${NOMAD_META_TIME}"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 64 # 256MB
      }
    }
  }
}