# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

config :data_collector, :emqtt,
  host: "127.0.0.1",
  clientid: "collector",
  port: 1883

config :data_collector, :kafka_producer,
  brokers: [{"localhost", 9092}],
  topic: "compacted_sensor_readings",
  sasl: {:plain, "kafkauser", "kafkapassword"}

config :data_generator, :emqtt,
  host: "127.0.0.1",
  port: 1883,
  clientid: "sensor"

config :data_generator,
  num_facilities: 3,
  reporting_interval: Duration.new!(second: 5)

config :data_server, http_server_port: 8080

config :data_server, :broadway,
  name: DataServer.Broadway,
  producer: [
    module:
      {BroadwayKafka.Producer,
       [
         hosts: [{"localhost", 9092}],
         group_id: "data_server_group",
         topics: ["compacted_sensor_readings"],
         client_config: [
           sasl: {:plain, "kafkauser", "kafkapassword"}
         ]
       ]},
    concurrency: 1
  ],
  processors: [
    default: [concurrency: 10]
  ]

config :data_server, storage: DataServer.Storage.Mongo

config :data_server, compacted_readings_coll_name: "compacted_sensor_readings"

config :data_server, DataServer.Storage.Mongo.Repo,
  url: "mongodb://localhost:27017/elixir-data-processing-demo",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000,
  username: "admin",
  password: "password",
  auth_source: "admin"

Logger.put_module_level(:emqtt, :error)
