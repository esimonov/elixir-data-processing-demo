defmodule FacilityCollector do
  use GenServer

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

    signal_state = Map.get(state.measurements, signal_name, %{sum: 0.0, count: 0})

    updated_signal_state = %{
      sum: signal_state.sum + value,
      count: signal_state.count + 1
    }

    updated_measurements_state = Map.put(state.measurements, signal_name, updated_signal_state)

    %{state | measurements: updated_measurements_state}
  end

  defp compose_aggregated_document(state) do
    measurements_state = Map.get(state, :measurements, %{})

    averages =
      Enum.map(
        measurements_state,
        fn
          {signal_name, %{sum: _sum, count: 0}} -> {"avg_#{signal_name}", 0}
          {signal_name, %{sum: sum, count: count}} -> {"avg_#{signal_name}", sum / count}
        end
      )
      |> Enum.into(%{facility_id: state.facility_id})

    # doc = %AggregatedDocument{}

    IO.puts(Jason.encode!(averages))
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
      :timer => Process.send_after(self(), :aggregate, 10_000)
    }
  end
end
