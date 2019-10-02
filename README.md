# Running in development mode

`nomad agent -dev`

or with a configuration

`nomad agent -dev --config config.hcl`

# Running a standalone server

`nomad agent --config standalone-server-conf.hcl`

Then, to connect an agent and start sending jobs to it:

`nomad agent --config standalone-agent-conf.hcl`

# Local Web console

[Web UI](http://localhost:4646)

# Docker image for a parametrized sleep job

`cd docker; docker build -t sleep-job:1 .`

# Registering a parameterized job

`nomad run parameterized-job.nomad`

# Running the parametrized job

`nomad job dispatch sleep` - with default values

`nomad job dispatch -meta TIME=360 sleep` - with custom sleep time

# Running a regular job

`nomad run regular-job.nomad`

# Listing jobs using API

`curl http://localhost:4646/v1/jobs | python -m json.tool`

`curl http://localhost:4646/v1/job/sleep/dispatch-xxxx-xxxxx | python -m json.tool`
