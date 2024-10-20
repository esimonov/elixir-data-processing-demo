defmodule DataCollector do
  use GenServer

  @moduledoc """
  Documentation for `DataCollector`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DataCollector.hello()
      :world

  """

  def start_link(_args), do: GenServer.start_link(__MODULE__, [])

  def init(_args) do
    {:ok, pid} = Application.get_env(:data_collector, :emqtt) |> :emqtt.start_link()

    state = %{pid: pid}

    {:ok, state, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = st) do
    {:ok, _} = :emqtt.connect(pid)

    {:ok, _, _} = :emqtt.subscribe(pid, {"measurements/#", 1})

    IO.puts("Collector subscribed")

    {:noreply, st}
  end

  def handle_info({:publish, publish}, st) do
    handle_publish(parse_topic(publish), publish, st)
  end

  defp handle_publish(["measurements", facility_id, signal_name], %{payload: _payload}, state) do
    IO.puts("Received: #{facility_id}, #{signal_name}")

    {:noreply, state}
  end

  defp handle_publish(_, _, state) do
    IO.puts("But why?")

    {:noreply, state}
  end

  defp parse_topic(%{topic: topic}) do
    String.split(topic, "/", trim: true)
  end
end
