defmodule AggregatedDocument do
  @enforce_keys [
    :facility_id,
    :window_start,
    :window_end
  ]
  defstruct [
    :facility_id,
    :window_start,
    :window_end,
    :avg_humidity,
    :avg_temperature,
    :avg_pressure,
    :max_humidity,
    :max_temperature,
    :max_pressure,
    :min_humidity,
    :min_temperature,
    :min_pressure
  ]
end
