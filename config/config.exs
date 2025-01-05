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

config :data_compactor, :emqtt,
  host: "127.0.0.1",
  clientid: "compactor",
  port: 1883

config :data_compactor,
  compaction_interval: Duration.new!(second: 10)

config :data_compactor, producer: DataCompactor.Producer.Kafka

config :data_generator, :emqtt,
  host: "127.0.0.1",
  port: 1883,
  clientid: "sensor"

config :data_generator,
  num_facilities: 3,
  reporting_interval: Duration.new!(second: 5)

config :data_server, http_server_port: 8080

config :data_server, storage: DataServer.Storage.Mongo

config :data_server, compacted_readings_coll_name: "compacted_sensor_readings"

Logger.put_module_level(:emqtt, :error)

import_config "config_#{config_env()}.exs"
