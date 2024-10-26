defmodule FacilityCollector do
  use GenServer

  def start_link(facility_id) do
    GenServer.start_link(__MODULE__, %{facility_id: facility_id}, name: via_tuple(facility_id))
  end

  defp via_tuple(facility_id), do: {:via, Registry, {Registry.Facilities, facility_id}}

  def init(_args) do
    {:ok, reset_state()}
  end

  def handle_cast({:measurement, signal_name, %{ts: _ts, val: value}}, state) do
    updated_state = update_measurement(state, signal_name, value)

    {:noreply, updated_state}
  end

  def handle_info(:aggregate, state) do
    compose_aggregated_document(Map.get(state, :measurements, %{}))

    {:noreply, reset_state()}
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

  defp compose_aggregated_document(measurements_state) do
    averages =
      Enum.map(
        measurements_state,
        fn
          {signal_name, %{sum: _sum, count: 0}} -> {"avg_#{signal_name}", 0}
          {signal_name, %{sum: sum, count: count}} -> {"avg_#{signal_name}", sum / count}
        end
      )
      |> Enum.into(%{})

    # doc = %AggregatedDocument{}

    IO.puts(Jason.encode!(averages))
  end

  defp reset_state() do
    %{
      measurements: %{},
      timer: Process.send_after(self(), :aggregate, 10_000)
    }
  end
end
