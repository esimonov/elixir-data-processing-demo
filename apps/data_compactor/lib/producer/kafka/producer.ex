defmodule DataCompactor.Producer.Kafka do
  @moduledoc """
  Module responsible for producing messages to Kafka.
  """

  use Supervisor

  alias Schema.Helpers.Encoder

  require Logger

  @table :kafka_config

  @behaviour DataCompactor.Behaviours.Producer

  def start_link(_opts) do
    Logger.info("Starting Data Compactor's Kafka Producer")

    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    config = Application.fetch_env!(:data_compactor, :kafka_producer)

    :ets.new(@table, [:named_table, :protected, read_concurrency: true])
    :ets.insert(@table, {:config, config})

    res =
      :brod.start_client(
        Keyword.fetch!(config, :brokers),
        :brod_client,
        auto_start_producers: true,
        sasl: Keyword.get(config, :sasl)
      )

    case res do
      :ok ->
        Logger.info("Data Compactor's Kafka Producer started")

        Supervisor.init([], strategy: :one_for_one, max_restarts: 10, max_seconds: 60)

      {:error, reason} ->
        Logger.info("Could not start Data Compactor's Kafka Producer: #{inspect(reason)}")
    end
  end

  def produce(%{facility_name: facility_name} = doc) do
    [{:config, config}] = :ets.lookup(@table, :config)

    :ok =
      :brod.produce_sync(
        :brod_client,
        Keyword.fetch!(config, :topic),
        :hash,
        facility_name,
        Encoder.encode_map(:compacted_reading, doc)
      )
  rescue
    e -> {:error, inspect(e)}
  end
end
