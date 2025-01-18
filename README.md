# Data Processing Pipeline

This project is a distributed system built to simulate, collect, process, store, and serve sensor data. Designed as an Elixir [umbrella project](https://elixirschool.com/en/lessons/advanced/umbrella_projects), it comprises multiple applications, each handling a specific part of the data pipeline:

- [Data Generator](/apps/data_generator/): Simulates sensor readings and publishes them.
- [Data Compactor](/apps/data_compactor/): Subscribes to sensor data, compacts it, and publishes compacted data.
- [Data Server](/apps/data_server/): Consumes compacted data, stores it, and exposes via a JSON API.
- [Schema](/apps/schema/): Contains the Protobuf schema definitions for the data model, as well as encoding/decoding helpers.

It’s primarily a learning project, aimed at exploring and gaining hands-on experience with Elixir's capabilities.

![High level overview](/assets/architecture.png)

### Key technologies used

- Messaging

  - [x] Kafka

    - [x] Producer
    - [x] Consumer

  - [x] MQTT

    - [x] Publisher
    - [x] Subscriber

- Storage

  - [x] MongoDB

    - [x] Find
    - [x] Insert
    - [x] Aggregate

- Data formats

  - [x] JSON:

    - [x] Decoding
    - [x] Encoding

  - [x] Protobuf:

    - [x] Decoding
    - [x] Encoding

- HTTP

  - [x] Server

    - [ ] Authentication
      - [ ] JWT

  - [ ] Client

- Continuous Integration:

  - [x] Linting
  - [x] Testing
    - [x] Test coverage with [ExCoveralls](https://github.com/parroty/excoveralls)

- Elixir-specific

  - [x] Custom Mix task for Protobuf schema compilation
  - [x] [DynamicSupervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html) for [GenServers](https://hexdocs.pm/elixir/GenServer.html)
  - [x] [Broadway](https://github.com/dashbitco/broadway) for data ingestion abstraction
  - [x] Custom Storage and Producer behaviours as an abstraction layer
  - [x] Interoperability with Erlang
    - [x] [emqtt](https://github.com/emqx/emqtt), MQTT client
    - [x] [brod](https://github.com/kafka4beam/brod), Kafka client
    - [x] [ets](https://www.erlang.org/docs/23/man/ets), term storage

- Misc:
  - [x] Docker
  - [x] [Contextive](https://github.com/dev-cycles/contextive) for Ubiquitous Language
  - [ ] Structured logging (JSON)

## Running locally

Requires Elixir 1.17+ and Docker Compose for running Kafka, MongoDB, and Mosquitto (MQTT broker).

```sh
# Start Kafka, MongoDB, MQTT.
docker compose -f docker/docker-compose.yml up -d

# Export secrets for Kafka and Mongo.
export $(cat .env.local | xargs) && iex -S mix

# Install and compile dependencies.
mix deps.get && mix deps.compile

# Start the apps.
iex -S mix
```

Now you can navigate to `http://localhost:8080/api/sensors/facility_1` to verify it's up and running.

## Running in Docker

If you don't have Elixir installed, the demo can be run in a Docker container.

```sh
# Build the image: the release (build artefact) will include all the three applications.
docker build --no-cache --tag data-processing-pipeline -f docker/Dockerfile . --progress=plain

# Start the app along with Kafka, MongoDB, MQTT.
docker compose -f docker/docker-compose.yml -f docker/docker-compose.override.yml up
```

Kafka container takes some time to stabilize, so encountering `errconnrefused` errors shortly after startup is normal.
