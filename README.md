# Running in development mode

`nomad agent -dev`

Or with a configuration:

`nomad agent -dev --config config.hcl`

# Running a standalone server

1. Change the `data_dir` path in _standalone-server-conf.hcl_ and _standalone-agent-conf.hcl_.

2. Start the server (a one-node cluster):

    `nomad agent --config standalone-server-conf.hcl`

3. Then, to connect an agent and start sending jobs to it:

    `nomad agent --config standalone-agent-conf.hcl`

# Local Web console

Access the [Web UI](http://localhost:4646)

# Docker image for a parametrized sleep job

`cd docker; docker build -t sleep-job:1 .`

# Registering the sample parameterized job

`nomad run parameterized-job.nomad`

# Running the sample parametrized job

With default values:

`nomad job dispatch sleep`

With custom sleep time:

`nomad job dispatch -meta TIME=360 sleep`

# Running the sample regular job (not parameterized)

`nomad run regular-job.nomad`

# Listing jobs using API

All jobs: 

`curl http://localhost:4646/v1/jobs | python -m json.tool`

Specific job (dispatch): 

`curl http://localhost:4646/v1/job/sleep/dispatch-xxxx-xxxxx | python -m json.tool`

# Reference documentation

- [Agent configuration](https://www.nomadproject.io/docs/configuration/index.html)
- [CLI commands](https://www.nomadproject.io/docs/commands/index.html)
- [HTTP API](https://www.nomadproject.io/api/index.html)
- [Job specification](https://www.nomadproject.io/docs/job-specification/index.html)