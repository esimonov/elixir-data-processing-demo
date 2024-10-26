defmodule FacilityCollector do
  use GenServer

  def start_link(facility_id) do
    GenServer.start_link(__MODULE__, %{facility_id: facility_id}, name: via_tuple(facility_id))
  end

  defp via_tuple(facility_id), do: {:via, Registry, {Registry.Facilities, facility_id}}

  def init(_args) do
    state = %{
      timer: nil,
      measurements: %{}
    }

    {:ok, schedule_aggregation(state)}
  end

  def handle_cast({:measurement, signal_name, %{ts: _ts, val: value}}, state) do
    updated_state = update_measurement(state, signal_name, value)

    {:noreply, updated_state}
  end

  def handle_info(:aggregate, state) do
    compose_aggregated_document(Map.get(state, :measurements, %{}))
  end

  defp update_measurement(state, signal_name, value) do
    IO.puts("Signal: #{signal_name}, val: #{value}")

    measurements_state = Map.get(state, :measurements, %{})

    signal_state = Map.get(measurements_state, signal_name, %{sum: 0.0, count: 0})

    updated_signal_state = %{
      sum: signal_state.sum + value,
      count: signal_state.count + 1
    }

    updated_measurements_state = Map.put(measurements_state, signal_name, updated_signal_state)

    %{state | measurements: updated_measurements_state}
  end

  defp compose_aggregated_document(measurements_state) do
    IO.puts(Jason.encode!(measurements_state))

    {:noreply, schedule_aggregation(%{:measurements => %{}, timer: nil})}
  end

  defp schedule_aggregation(state) do
    timer = Process.send_after(self(), :aggregate, 10_000)

    %{state | timer: timer}
  end
end
