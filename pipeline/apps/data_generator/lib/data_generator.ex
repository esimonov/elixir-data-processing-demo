defmodule DataGenerator do
  use GenServer

  @reported_signals [
    %{name: "humidity", average: 50},
    %{name: "pressure", average: 1013},
    %{name: "temperature", average: 20}
  ]

  def start(_type, _args) do
    IO.puts("Starting Data Generator")

    DataGenerator.start_link([])
  end

  # GenServer boilerplate
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @moduledoc """
  Documentation for `DataGenerator`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DataGenerator.hello()
      :world

  """
  def init(_args) do
    {:ok, pid} = Application.get_env(:data_generator, :emqtt) |> :emqtt.start_link()

    state = %{
      pid: pid,
      timer: nil,
      reporting_interval: Application.get_env(:data_generator, :reporting_interval),
      num_facilities: Application.get_env(:data_generator, :num_facilities)
    }

    {:ok, set_timer(state), {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = state) do
    {:ok, _} = :emqtt.connect(pid)

    {:noreply, state}
  end

  def handle_info(:tick, %{pid: pid, num_facilities: num_facilities} = state) do
    report_measurements(pid, num_facilities)

    {:noreply, set_timer(state)}
  end

  defp set_timer(%{reporting_interval: reporting_interval} = state) do
    timer = Process.send_after(self(), :tick, to_timeout(reporting_interval))

    %{state | timer: timer}
  end

  defp report_measurements(pid, num_facilities) do
    1..num_facilities
    |> Stream.flat_map(fn i ->
      Stream.map(
        @reported_signals,
        fn %{name: signal_name, average: signal_avg} ->
          {
            get_topic_name(i, signal_name),
            generate_measurement(signal_avg)
          }
        end
      )
    end)
    |> Task.async_stream(fn {topic_name, payload} -> :emqtt.publish(pid, topic_name, payload) end)
    |> Stream.run()
  end

  defp get_topic_name(facility_num, signal_name) do
    "measurements/facility_#{facility_num}/#{signal_name}"
  end

  defp generate_measurement(avg_signal_value) do
    # TODO: use map?
    {
      System.system_time(:millisecond),
      :rand.normal(avg_signal_value, 0.5)
    }
    |> :erlang.term_to_binary()
  end
end
