defmodule DataGenerator do
  @moduledoc """
  A GenServer-based data generator for simulating sensor readings across multiple facilities.

  This module generates synthetic readings for sensors like humidity, pressure, and temperature,
  publishing them to MQTT topics at regular intervals.

  The sensor readings are normally distributed random values with μs hardcoded as module attributes,
  and σ²s directly proportional to the ordinal number of the facility, e.g
  the higher the number of the facility, the more variance its sensor readings show.

  The topics names are in the form of "sensor_readings/{facility_name}/{sensor_name}".
  E.g, "sensor_readings/facility_2/pressure" is a topic for pressure readings from facility_2.

  The number of facilities and reporting interval can be configured through application environment variables.

  ## Configuration

  - `:num_facilities` - The total number of facilities to simulate.
  - `:reporting_interval` - Time interval between sensor reading simulations.
  """
  use GenServer

  require Logger

  @sensors [
    %{name: "humidity", mean: 50},
    %{name: "pressure", mean: 1013},
    %{name: "temperature", mean: 20}
  ]

  @min_variance_percent 1
  @max_variance_percent 10

  @num_facilities Application.compile_env!(:data_generator, :num_facilities)

  def start(_type, _args) do
    Logger.info("Starting Data Generator")

    DataGenerator.start_link([])
  end

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_args) do
    {:ok, pid} = Application.get_env(:data_generator, :emqtt) |> :emqtt.start_link()

    state = %{
      pid: pid,
      timer: nil,
      reporting_interval: Application.get_env(:data_generator, :reporting_interval)
    }

    {:ok, set_timer(state), {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = state) do
    {:ok, _} = :emqtt.connect(pid)

    {:noreply, state}
  end

  def handle_info(:tick, %{pid: pid} = state) do
    report_readings(pid)

    {:noreply, set_timer(state)}
  end

  def terminate(_reason, %{pid: pid}) do
    :emqtt.disconnect(pid)

    Logger.info("Data generator disconnected")

    :ok
  end

  defp set_timer(%{reporting_interval: reporting_interval} = state) do
    timer = Process.send_after(self(), :tick, to_timeout(reporting_interval))

    %{state | timer: timer}
  end

  defp report_readings(pid) do
    1..@num_facilities
    |> Stream.flat_map(fn facility_num ->
      Stream.map(
        @sensors,
        fn %{name: sensor_name, mean: mean_value} ->
          {
            get_topic_name(facility_num, sensor_name),
            generate_reading(facility_num, mean_value)
          }
        end
      )
    end)
    |> Task.async_stream(fn {topic_name, payload} ->
      case :emqtt.publish(pid, topic_name, payload) do
        :ok -> :ok
        {:error, reason} -> Logger.error("Failed to publish to #{topic_name}: #{inspect(reason)}")
      end
    end)
    |> Stream.run()
  end

  defp generate_reading(facility_num, mean_value) do
    min_variance = @min_variance_percent * mean_value / 100

    max_variance = @max_variance_percent * mean_value / 100

    step = (max_variance - min_variance) / @num_facilities

    # The higher the number of the facility, the more variance its sensor readings show.
    variance = min_variance + step * facility_num

    Jason.encode!(%{
      "ts" => System.system_time(:millisecond),
      "val" => :rand.normal(mean_value, variance)
    })
  end

  defp get_topic_name(facility_num, sensor_name) do
    "sensor_readings/facility_#{facility_num}/#{sensor_name}"
  end
end
