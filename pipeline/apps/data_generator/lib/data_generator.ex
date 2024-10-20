defmodule DataGenerator do
  use GenServer

  def start(_type, _args) do
    IO.puts("Starting Data Generator")

    DataGenerator.start_link([])
  end

  # GenServer boilerplate
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

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
    emqtt_opts = Application.get_env(:data_generator, :emqtt)

    interval = Application.get_env(:data_generator, :interval)

    report_topic = "reports/#{emqtt_opts[:client_id]}/temperature"

    {:ok, pid} = :emqtt.start_link(emqtt_opts)

    state = %{
      timer: nil,
      interval: interval,
      report_topic: report_topic,
      pid: pid
    }

    {:ok, set_timer(state), {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid} = st) do
    {:ok, _} = :emqtt.connect(pid)

    {:noreply, st}
  end

  def handle_info(:tick, %{report_topic: topic, pid: pid} = state) do
    report_temperature(pid, topic)

    {:noreply, set_timer(state)}
  end

  defp set_timer(state) do
    timer = Process.send_after(self(), :tick, to_timeout(state.interval))

    %{state | timer: timer}
  end

  defp report_temperature(pid, topic) do
    temperature = 10.0 + 2.0 * :rand.normal()
    message = {System.system_time(:millisecond), temperature}
    payload = :erlang.term_to_binary(message)
    :emqtt.publish(pid, topic, payload)
  end
end
