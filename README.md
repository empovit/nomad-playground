This demonstrates running [Hashicorp Nomad](https://www.nomadproject.io/) in a client-server mode, with [Nomad Firehose](https://github.com/seatgeek/nomad-firehose) polling Nomad API endpoints and publishing events to [RabbitMQ](https://www.rabbitmq.com/).

# Pre-requisites

1. We will be running Nomad (both server and client) directly on the local machine. Therefore, you will need to [install Nomad](https://www.nomadproject.io/guides/install/index.html) first, e.g. `brew install nomad`.

2. Same goes for Nomad Firehose. Install is as described on the [project's page](https://github.com/seatgeek/nomad-firehose).

3. You will need [Docker](https://www.docker.com/) in order to run the other software used in this demonstration, as well as to place Nomad jobs using Docker driver.

4. Some scripts require a Linux shell and Python 3.x.

# Nomad Data Directory

Make sure to change the `data_dir` path in [standalone-server-conf.hcl](standalone-server-conf.hcl) and [standalone-client-conf.hcl](standalone-client-conf.hcl).

**NOTE**: If you encounter problems starting the server on subsequent runs, and are OK with _losing any persistent data_ of the test Nomad cluster, delete the data directory. 

# Start Nomad

1. Server: `nomad agent --config standalone-server-conf.hcl` (view [standalone-server-conf.hcl](standalone-server-conf.hcl))

2. Client: `nomad agent --config standalone-client-conf.hcl` (view [standalone-client-conf.hcl](standalone-client-conf.hcl))

# Run a Job

* We have a simple `sleep` command with the time given as a parameter, packaged as a Docker image (see [entrypoint.sh](docker/entrypoint.sh)). To build the image, run `cd docker; docker build -t sleep-job:1 .`

* Run a regular job defined in [regular-job.nomad](regular-job.nomad). It sleeps 2 min:  `nomad run regular-job.nomad`

* Load the parametrized job defined in [parameterized-job.nomad](parameterized-job.nomad): `nomad run parameterized-job.nomad`

* Create a dispatch with either the default sleep time of 60 sec: `nomad job dispatch sleep`, or a custom sleep time (6 min in this case): `nomad job dispatch -meta TIME=360 sleep`

# Try Some Commands

* `nomad agent` and `nomad job` commands above
* `nomad job status`
* `nomad ui` to access the [Web UI](http://localhost:4646)
* `nomad job stop` with a job ID
* `nomad job stop` with a dispatch ID
* Check out the [CLI command reference](https://www.nomadproject.io/docs/commands/index.html).

# Explore the [Web UI](http://localhost:4646)

1. Jobs
2. Job definition
3. Job dispatches
4. Dispatch allocations
5. Evaluations
6. Clients
7. Servers

# Explore API Endpoints

1. View all jobs: [http://localhost:4646/v1/jobs](http://localhost:4646/v1/jobs) or `curl http://localhost:4646/v1/jobs | python -m json.tool`

2. View a job/dispatch: [http://localhost:4646/v1/job/sleep/dispatch-xxxx-xxxxx](http://localhost:4646/v1/job/sleep/dispatch-xxxx-xxxxx) or `curl http://localhost:4646/v1/job/sleep/dispatch-xxxx-xxxxx | python -m json.tool` (replace with a dispatch ID).

3. Notice that _/jobs_ vs _/job/xxx_ does not follow the RESTful convention.

4. Try [blocking queries](https://www.nomadproject.io/api/index.html#blocking-queries):

  * Open [http://localhost:4646/v1/jobs](http://localhost:4646/v1/jobs).
  
  * Note the value of the _X-Nomad-Index_ header (via the developer tools).

  * Run [http://localhost:4646/v1/jobs?index=xxx](http://localhost:4646/v1/jobs=xxx) (replace with the index value).

  * Observe the page waiting on long poll.

  * Submit another dispatch: `nomad job dispatch -meta TIME=360 sleep`
  
  * Note a new value of the _X-Nomad-Index_ header.

  * Try running the query with the new index and stopping the dispatch.

* Check out the [API reference](https://www.nomadproject.io/api/index.html). APIs that support blocking queries are explicitly documented as such.

# Connect Firehose 

1. Start RabbitMQ

  * Run RabbitMQ: `docker run -d --hostname local-rabbitmq --name rabbitmq -p 15672:15672 -p 5672:5672 rabbitmq:3.8-management`

  * Declare queues and exchanges for Nomad allocations: `./rabbit_setup.sh allocations` (view [rabbit_setup.sh](rabbit_setup.sh))

  * Open the dashboard [http://localhost:15672/](http://localhost:15672/) (with _guest/guest_ credentials).

2. Start [Consul](https://www.consul.io/): `docker run -d --name consul -p 8500:8500 consul:1.6`

3. Start Firehose to monitor the [_allocations_](http://localhost:4646/v1/allocations) endpoint: `./firehose.sh allocations` (view [firehose.sh](firehose.sh)). It acquires a Consul lock.

4. Let's see how Firehose fail-over works. Start another Firehose instance to monitor the same endpoint: `./firehose.sh allocations`. It will block trying to acquire a Consul lock.

5. Send dispatches: `for i in {1..100}; do nomad job dispatch sleep; sleep 3; done`

6. See the messages being accumulated in the [allocations queue](http://localhost:15672/#/queues/%2F/nomad-allocations).

7. See two [connections](http://localhost:15672/#/connections) in RabbitMQ that correspond to the two Firehose instances.

8. Close the instance of Firehose that is holding the Consul lock. See one connection go away, the other Firehose taking the lock and starting to publish messages.

# Build Nomad Locally

For this section you need Go language tools and _GNU make_ installed, and GOPATH environment variable defined.

1. Go requires all sources to reside under \$GOPATH/src. Clone the [Nomad repository](https://github.com/hashicorp/nomad) into _\$GOPATH/src/github.com/hashicorp_ (`mkdir -p $GOPATH/src/github.com/hashicorp; cd $GOPATH/src/github.com/hashicorp; git clone git@github.com:hashicorp/nomad.git --depth 1 --single-branch`).

2. I like all my projects to sit under a development folder. Let's say _~/dev_. Therefore, I created a symbolic link to the clone of Nomad in that directory: `ln -s $GOPATH/src/github.com/hashicorp/nomad ~/dev/nomad`.

3. Navigate to the Nomad source: `cd $GOPATH/src/github.com/hashicorp/nomad`.

4. Run `make bootstrap`. Some errors related to missing files or directories are OK.

5. Run `make dev` to build a development version of Nomad.

6. Now start the locally built version of Nomad using `./bin/nomad` (instead of `nomad`).

7. Try to print a message in _RunCustom()_ of _main.go_. E.g. `fmt.Printf("### WARNING! This a local version of Nomad ###\n")`.

8. Build and run `make dev; ./bin/nomad agent --dev`.

Keep in mind that Nomad uses [govendor](https://github.com/kardianos/govendor) for managing dependencies. Do not use `go get` directly to install packages.

# Reference Documentation

- [Agent configuration](https://www.nomadproject.io/docs/configuration/index.html)
- [CLI commands](https://www.nomadproject.io/docs/commands/index.html)
- [HTTP API](https://www.nomadproject.io/api/index.html)
- [Job specification](https://www.nomadproject.io/docs/job-specification/index.html)