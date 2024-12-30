defmodule FacilityCollector do
  require Logger
  use GenServer

  @aggregations [
    "avg",
    "min",
    "max"
  ]

  def start_link(facility_id) do
    GenServer.start_link(
      __MODULE__,
      %{facility_id: facility_id},
      name: via(facility_id)
    )
  end

  defp via(facility_id), do: {:via, Registry, {Registry.Facilities, facility_id}}

  def init(%{facility_id: facility_id}) do
    {:ok, reset_state(facility_id)}
  end

  def handle_cast({sensor_name, %{val: value}}, state) do
    updated_state = update_readings_state(state, sensor_name, value)

    {:noreply, updated_state}
  end

  def handle_info(:compact_readings, %{facility_id: facility_id} = state) do
    with doc <- compact_readings(state),
         :ok <- DataCollector.KafkaProducer.produce(doc) do
    else
      {:error, reason} ->
        Logger.error("Producing compacted reading: #{inspect(reason)}")
    end

    {:noreply, reset_state(facility_id)}
  end

  defp update_readings_state(state, sensor_name, value) do
    IO.puts("Sensor: #{sensor_name}, val: #{value}")

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
      facility_id: state.facility_id,
      window_start: state.window_start,
      window_end: DateTime.utc_now()
    })
  end

  defp reset_state(facility_id) do
    %{
      facility_id: facility_id,
      readings: %{},
      window_start: DateTime.utc_now(),
      timer: Process.send_after(self(), :compact_readings, 10_000)
    }
  end

  defp aggregate(%{sum: sum, count: count}, "avg"),
    do: if(count > 0, do: sum / count, else: 0)

  defp aggregate(%{max: max}, "max"), do: max
  defp aggregate(%{min: min}, "min"), do: min
end
