defmodule FacilityCollector do
  use GenServer

  def start_link(facility_id) do
    GenServer.start_link(__MODULE__, %{facility_id: facility_id}, name: via_tuple(facility_id))
  end

  defp via_tuple(facility_id), do: {:via, Registry, {Registry.Facilities, facility_id}}

  def init(state), do: {:ok, Map.put(state, :measurements, %{})}

  def handle_cast({:measurement, signal_name, %{ts: _ts, val: value}}, state) do
    updated_state = update_measurement(state, signal_name, value)

    {:noreply, updated_state}
  end

  defp update_measurement(state, signal_name, value) do
    IO.puts("Signal: #{signal_name}, val: #{value}")

    {:noreply, state}
  end
end
