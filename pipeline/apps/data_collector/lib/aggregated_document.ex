defmodule AggregatedDocument do
  @enforce_keys [
    :facility_id,
    :avg_humidity,
    :avg_temperature,
    :avg_pressure,
    :window_start,
    :window_end
  ]
  defstruct @enforce_keys
end
