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

config :data_generator, :emqtt,
  host: "127.0.0.1",
  port: 1883,
  clientid: "sensor"

config :data_generator,
  num_facilities: 5,
  reporting_interval: Duration.new!(second: 5)
