defmodule DataCompactor do
  @moduledoc """
  The `DataCompactor` module is a GenServer responsible for subscribing to sensor reading topics,
  processing (compacting) incoming messages, and routing validated sensor readings to appropriate facility compactors.
  """
  use GenServer

  require Logger

  @sensor_names [
    "humidity",
    "pressure",
    "temperature"
  ]

  @topics_prefix "sensor_readings"

  def start_link(_args) do
    Logger.info("Starting Data Compactor")

    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    {:ok, pid} = Application.get_env(:data_compactor, :emqtt) |> :emqtt.start_link()

    {:ok, %{pid: pid}, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = state) do
    {:ok, _} = :emqtt.connect(pid)

    Enum.each(
      @sensor_names,
      fn name ->
        {:ok, _, _} = :emqtt.subscribe(pid, {compose_topic(name), 1})
      end
    )

    Logger.info("Compactor subscribed")

    {:noreply, state}
  end

  def handle_info({:publish, publish}, state) do
    handle_publish(parse_topic(publish), publish, state)
  end

  defp handle_publish(
         [@topics_prefix, facility_name, sensor_name],
         %{payload: payload},
         state
       ) do
    case validate_sensor_reading(payload) do
      {:ok, %{ts: ts, val: value}} ->
        route_message(facility_name, sensor_name, %{ts: ts, val: value})

      {:error, reason} ->
        Logger.error("Validating sensor reading: #{reason}")
    end

    {:noreply, state}
  end

  defp route_message(facility_name, sensor_name, %{ts: ts, val: value}) do
    pid =
      case Registry.lookup(Registry.Facilities, facility_name) do
        [{pid, _}] ->
          pid

        [] ->
          {:ok, pid} = FacilitySupervisor.start_child(facility_name)
          pid
      end

    GenServer.cast(pid, {sensor_name, %{ts: ts, val: value}})
  end

  defp validate_sensor_reading(json_string) do
    case Jason.decode(json_string) do
      {:ok, %{"ts" => ts, "val" => value}} -> {:ok, %{ts: ts, val: value}}
      {:ok, _} -> {:error, "Invalid payload structure: #{json_string}"}
      {:error, error} -> {:error, Jason.DecodeError.message(error)}
    end
  end

  defp compose_topic(sensor_name), do: "#{@topics_prefix}/+/#{sensor_name}"

  defp parse_topic(%{topic: topic}), do: String.split(topic, "/", trim: true)
end
