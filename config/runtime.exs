import Config

config :data_collector, :kafka_producer,
  brokers: [{"localhost", 9092}],
  topic: "compacted_sensor_readings",
  sasl: {:plain, System.get_env("KAFKA_USER"), System.get_env("KAFKA_PASSWORD")}

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
           sasl: {:plain, System.get_env("KAFKA_USER"), System.get_env("KAFKA_PASSWORD")}
         ]
       ]},
    concurrency: 1
  ],
  processors: [
    default: [concurrency: 3]
  ]

config :data_server, DataServer.Storage.Mongo.Repo,
  url: "mongodb://localhost:27017/elixir-data-processing-demo",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000,
  username: System.get_env("MONGO_USER"),
  password: System.get_env("MONGO_PASSWORD"),
  auth_source: "admin"
