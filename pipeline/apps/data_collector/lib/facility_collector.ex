defmodule FacilityCollector do
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
    aggregated_doc =
      state
      |> Map.get(:measurements, %{})
      |> Stream.flat_map(fn {signal_name, measurement} ->
        Stream.map(
          @aggregations,
          fn agg -> compute_aggregation(signal_name, measurement, agg) end
        )
      end)
      |> Enum.into(%{
        facility_id: state.facility_id,
        window_start: state.window_start,
        window_end: DateTime.utc_now()
      })

    # doc = %AggregatedDocument{}

    IO.puts(Jason.encode!(aggregated_doc))
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

  defp compute_aggregation(signal_name, %{sum: sum, count: count}, "avg") do
    {"avg_#{signal_name}", if(count > 0, do: sum / count, else: 0)}
  end

  defp compute_aggregation(signal_name, %{max: max}, "max"), do: {"max_#{signal_name}", max}
  defp compute_aggregation(signal_name, %{min: min}, "min"), do: {"min_#{signal_name}", min}
end
