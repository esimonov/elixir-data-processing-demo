# Data Compactor

This app subscribes to the data published by [Data Generator](/apps/data_generator/) and aggregates it into larger batches. The motivation here is that sensors may submit an excessive amount of data, which can be safely replaced with an aggregated representation - such as the maximum, minimum, and average values of the readings - within a time window larger than the sensor's reporting interval. We refer to this process as compaction.

Then, compacted batches are [Protobuf-encoded](/apps/schema/) and produced to Kafka. The Producer is defined as a Behaviour, allowing for alternative implementations other than Kafka.

## Configuration

The following parameters are configurable:

- `:compaction_interval` - The size of the time window between consequtive data compactions.

### MQTT subscription and dynamic supervision

The app subscribes to three topics with a single-level wildcard in the place for facility name: `sensor_readings/+/humidity`, `sensor_readings/+/pressure`, `sensor_readings/+/temperature`. This allows new facilities to be added dynamically, which makes a use case for [DynamicSupervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html): each facility is supervised separately, and when sensor reading from a new facility arrives, this adds a new supervisor to the registry.
