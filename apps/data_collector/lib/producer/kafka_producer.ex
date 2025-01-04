defmodule DataCollector.KafkaProducer do
  @moduledoc """
  Module responsible for producing messages to Kafka.
  """

  use Supervisor

  alias Schema.Helpers.Encoder

  @table :kafka_config

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    config = Application.fetch_env!(:data_collector, :kafka_producer)

    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    :ets.insert(@table, {:config, config})

    :ok =
      :brod.start_client(
        Keyword.fetch!(config, :brokers),
        :brod_client,
        auto_start_producers: true,
        sasl: Keyword.get(config, :sasl)
      )

    Supervisor.init([], strategy: :one_for_one)
  end

  def produce(%{facility_id: facility_id} = doc) do
    [{:config, config}] = :ets.lookup(@table, :config)

    :ok =
      :brod.produce_sync(
        :brod_client,
        Keyword.fetch!(config, :topic),
        :hash,
        facility_id,
        Encoder.encode_map(:compacted_reading, doc)
      )
  rescue
    e -> {:error, e}
  end
end
