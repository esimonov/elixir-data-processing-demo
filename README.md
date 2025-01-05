# Data Processing Pipeline

This demo is a distributed system designed to simulate, collect, process, store, and serve sensor data. It includes multiple applications running under an Elixir [umbrella project](https://elixirschool.com/en/lessons/advanced/umbrella_projects), each responsible for a specific part of the data pipeline:

- [Data Generator](/apps/data_generator/): Simulates sensor readings and publishes them.
- [Data Compactor](/apps/data_compactor/): Subscribes to sensor data, compacts it, and publishes compacted data.
- [Data Server](/apps/data_server/): Consumes compacted data, stores it, and exposes via a JSON API.
- [Schema](/apps/schema/): Contains the Protobuf schema definitions for the data model, as well as encoding/decoding helpers.

### Key technologies used

- Messaging

  - Kafka

    - [x] Producer
    - [x] Consumer

  - MQTT

    - [x] Publisher
    - [x] Subscriber

- Storage

  - MongoDB
    - [x] Find
    - [x] Insert
    - [x] Aggregate

- Data formats

  - JSON:

    - [x] Decoding
    - [x] Encoding

  - Protobuf:

    - [x] Decoding
    - [x] Encoding

- HTTP

  - [x] Server

    - Authentication
      - [ ] JWT

  - [ ] Client

- Continuous Integration:

  - [x] Linting
  - [x] Testing

- Elixir-specific

  - [x] Custom Mix task for Protobuf schema compilation
  - [x] [DynamicSupervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html)
  - Interoperability with Erlang
    - [x] [emqtt](https://github.com/emqx/emqtt)
    - [x] [ets](https://www.erlang.org/docs/23/man/ets)

- Various:

  - [x] [Contextive](https://github.com/dev-cycles/contextive) for Ubiquitous Language
  - [ ] Structured logging (JSON)

#
