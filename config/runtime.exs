import Config

require Logger

config :data_generator, :emqtt,
  host: System.get_env("MQTT_HOST"),
  port: System.get_env("MQTT_PORT") |> String.to_integer(),
  clientid: "generator"

config :data_compactor, :emqtt,
  host: System.get_env("MQTT_HOST"),
  port: System.get_env("MQTT_PORT") |> String.to_integer(),
  clientid: "compactor"

kafka_brokers = [
  {
    System.get_env("KAFKA_HOST"),
    System.get_env("KAFKA_PORT") |> String.to_integer()
  }
]

kafka_credentials = {
  :plain,
  System.get_env("KAFKA_USER"),
  System.get_env("KAFKA_PASSWORD")
}

config :data_compactor, :kafka_producer,
  brokers: kafka_brokers,
  topic: "compacted_sensor_readings",
  sasl: kafka_credentials

config :data_server, :broadway,
  name: DataServer.Broadway,
  producer: [
    module:
      {BroadwayKafka.Producer,
       [
         hosts: kafka_brokers,
         group_id: "data_server_group",
         topics: ["compacted_sensor_readings"],
         client_config: [sasl: kafka_credentials]
       ]},
    concurrency: 1
  ],
  processors: [
    default: [concurrency: 3]
  ]

config :data_server, DataServer.Storage.Mongo.Repo,
  url:
    "mongodb://#{System.get_env("MONGO_HOST")}:#{System.get_env("MONGO_PORT")}/elixir-data-processing-demo",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000,
  username: System.get_env("MONGO_USER"),
  password: System.get_env("MONGO_PASSWORD"),
  auth_source: "admin"

Logger.put_module_level(:emqtt, :error)
