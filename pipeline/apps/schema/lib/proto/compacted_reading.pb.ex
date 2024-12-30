defmodule Schema.CompactedReading do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:facility_id, 1, type: :string, json_name: "facilityId")
  field(:window, 2, type: Schema.Interval)
  field(:avg_humidity, 4, type: :double, json_name: "avgHumidity")
  field(:avg_temperature, 5, type: :double, json_name: "avgTemperature")
  field(:avg_pressure, 6, type: :double, json_name: "avgPressure")
  field(:max_humidity, 7, type: :double, json_name: "maxHumidity")
  field(:max_temperature, 8, type: :double, json_name: "maxTemperature")
  field(:max_pressure, 9, type: :double, json_name: "maxPressure")
  field(:min_humidity, 10, type: :double, json_name: "minHumidity")
  field(:min_temperature, 11, type: :double, json_name: "minTemperature")
  field(:min_pressure, 12, type: :double, json_name: "minPressure")
end

defmodule Schema.Interval do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:start_time, 1, type: Google.Protobuf.Timestamp, json_name: "startTime")
  field(:end_time, 2, type: Google.Protobuf.Timestamp, json_name: "endTime")
end
