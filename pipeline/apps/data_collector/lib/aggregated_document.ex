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
    :avg_pressure
  ]
end
