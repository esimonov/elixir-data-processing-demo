defmodule FacilityCompactor do
  @moduledoc """
  A GenServer implementation for collecting and compacting sensor readings for a specific facility.

  `FacilityCompactor` manages the aggregation of sensor data (e.g., humidity, temperature, pressure)
  for a single facility. It periodically compacts these readings into a document and publishes it
  to message broker for further processing.

  ## Configuration

  - `:compaction_interval`: Time interval for compacting sensor readings. Set in the application environment for `:data_compactor`.
  """
  require Logger
  use GenServer

  alias DataCompactor.Producer

  @aggregations [
    "avg",
    "min",
    "max"
  ]

  @compaction_interval Application.compile_env!(:data_compactor, :compaction_interval)

  def start_link(facility_name) do
    Logger.info("Starting Compactor for #{facility_name}")

    GenServer.start_link(
      __MODULE__,
      %{facility_name: facility_name},
      name: via(facility_name)
    )
  end

  defp via(facility_name), do: {:via, Registry, {Registry.Facilities, facility_name}}

  def init(%{facility_name: facility_name}) do
    {:ok, reset_state(facility_name)}
  end

  def handle_cast({sensor_name, %{val: value}}, state) do
    updated_state = update_readings_state(state, sensor_name, value)

    {:noreply, updated_state}
  end

  def handle_info(:compact_readings, %{facility_name: facility_name} = state) do
    with doc <- compact_readings(state),
         :ok <- Producer.produce(doc) do
    else
      {:error, reason} ->
        Logger.error("Producing compacted reading: #{inspect(reason)}")
    end

    {:noreply, reset_state(facility_name)}
  end

  defp update_readings_state(%{facility_name: facility_name} = state, sensor_name, value) do
    Logger.debug(
      "Updating readings state: #{sensor_name}, facility: #{facility_name}, value: #{value}"
    )

    sensor_state =
      Map.get(
        state.readings,
        sensor_name,
        %{count: 0, sum: nil, max: nil, min: nil}
      )

    updated_state = %{
      count: sensor_state.count + 1,
      sum: (sensor_state.sum || 0) + value,
      max: max(sensor_state.max || value, value),
      min: min(sensor_state.min || value, value)
    }

    %{state | readings: Map.put(state.readings, sensor_name, updated_state)}
  end

  defp compact_readings(state) do
    # Loads struct field name atoms.
    {:module, _} = Code.ensure_loaded(Schema.CompactedReading)

    state
    |> Map.get(:readings, %{})
    |> Enum.flat_map(fn {sensor_name, reading} ->
      Enum.map(
        @aggregations,
        fn agg ->
          {
            "#{agg}_#{sensor_name}" |> String.to_existing_atom(),
            aggregate(reading, agg)
          }
        end
      )
    end)
    |> Enum.into(%{
      facility_name: state.facility_name,
      window_start: state.window_start,
      window_end: DateTime.utc_now()
    })
  end

  defp reset_state(facility_name) do
    %{
      facility_name: facility_name,
      readings: %{},
      window_start: DateTime.utc_now(),
      timer: Process.send_after(self(), :compact_readings, to_timeout(@compaction_interval))
    }
  end

  defp aggregate(%{sum: sum, count: count}, "avg"),
    do: if(count > 0, do: sum / count, else: 0)

  defp aggregate(%{max: max}, "max"), do: max
  defp aggregate(%{min: min}, "min"), do: min
end
