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

  @signal_names [
    "humidity",
    "pressure",
    "temperature"
  ]

  def start_link(_args), do: GenServer.start_link(__MODULE__, [])

  def init(_args) do
    {:ok, pid} = Application.get_env(:data_collector, :emqtt) |> :emqtt.start_link()

    state = %{pid: pid}

    {:ok, state, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = state) do
    {:ok, _} = :emqtt.connect(pid)

    Enum.each(
      @signal_names,
      fn signal_name ->
        {:ok, _, _} = :emqtt.subscribe(pid, {"measurements/+/#{signal_name}", 1})
      end
    )

    IO.puts("Collector subscribed")

    {:noreply, state}
  end

  def handle_info({:publish, publish}, state) do
    handle_publish(parse_topic(publish), publish, state)
  end

  defp handle_publish(
         ["measurements", facility_id, signal_name],
         %{payload: payload},
         state
       ) do
    case validate_measurement_json(payload) do
      {:ok, %{ts: ts, val: value}} ->
        IO.puts("Received: #{facility_id}, #{signal_name}, timestamp:#{ts}, value:#{value}")

      {:error, reason} ->
        IO.puts("Error! #{reason}")
    end

    {:noreply, state}
  end

  defp parse_topic(%{topic: topic}), do: String.split(topic, "/", trim: true)

  defp validate_measurement_json(json_string) do
    case Jason.decode(json_string) do
      {:ok, %{"ts" => ts, "val" => value}} -> {:ok, %{ts: ts, val: value}}
      _ -> {:error, "Could not decode JSON"}
    end
  end
end
