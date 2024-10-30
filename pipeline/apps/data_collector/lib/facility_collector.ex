defmodule FacilityCollector do
  require Logger
  use GenServer

  @aggregations ["avg", "min", "max"]

  def start_link(facility_id) do
    GenServer.start_link(__MODULE__, %{facility_id: facility_id}, name: via_tuple(facility_id))
  end

  defp via_tuple(facility_id), do: {:via, Registry, {Registry.Facilities, facility_id}}

  def init(args) do
    {:ok, reset_state(args.facility_id)}
  end

  def handle_cast({:measurement, signal_name, %{ts: _ts, val: value}}, state) do
    updated_state = update_measurement(state, signal_name, value)

    {:noreply, updated_state}
  end

  def handle_info(:aggregate, state) do
    compose_aggregated_document(state)

    {:noreply, reset_state(state)}
  end

  defp update_measurement(state, signal_name, value) do
    IO.puts("Signal: #{signal_name}, val: #{value}")

    signal_state =
      Map.get(
        state.measurements,
        signal_name,
        %{sum: 0.0, count: 0, max: nil, min: nil}
      )

    updated_signal_state = %{
      sum: signal_state.sum + value,
      count: signal_state.count + 1,
      max: max(signal_state.max || value, value),
      min: min(signal_state.min || value, value)
    }

    %{state | measurements: Map.put(state.measurements, signal_name, updated_signal_state)}
  end

  defp compose_aggregated_document(state) do
    # Loads struct field name atoms.
    {:module, _} = Code.ensure_loaded(Schema.AggregatedDocument)

    aggregated_signals =
      state
      |> Map.get(:measurements, %{})
      |> Enum.flat_map(fn {signal_name, measurement} ->
        Enum.map(
          @aggregations,
          fn agg ->
            {
              "#{agg}_#{signal_name}" |> String.to_existing_atom(),
              compute_aggregation(measurement, agg)
            }
          end
        )
      end)
      |> Enum.into(%{
        facility_id: state.facility_id,
        window: %{
          start_time: state.window_start,
          end_time: DateTime.utc_now()
        }
      })

    doc = struct(Schema.AggregatedDocument, aggregated_signals)

    doc |> inspect |> Logger.debug()
  end

  defp reset_state(%{:facility_id => facility_id} = state) do
    state
    |> Map.get(state, facility_id)
    |> reset_state
  end

  defp reset_state(facility_id) do
    %{
      :facility_id => facility_id,
      :measurements => %{},
      :window_start => DateTime.utc_now(),
      :timer => Process.send_after(self(), :aggregate, 10_000)
    }
  end

  defp compute_aggregation(%{sum: sum, count: count}, "avg"),
    do: if(count > 0, do: sum / count, else: 0)

  defp compute_aggregation(%{max: max}, "max"), do: max
  defp compute_aggregation(%{min: min}, "min"), do: min
end
