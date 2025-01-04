defmodule DataCollector.KafkaProducer do
  @moduledoc """
  Module responsible for producing messages to Kafka.
  """

  use Supervisor

  alias Schema.Helpers.Encoder

  @kafka_config Application.compile_env!(:data_collector, :kafka_producer)

  def start_link(_config) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ok =
      :brod.start_client(
        Keyword.get(@kafka_config, :brokers),
        :brod_client,
        auto_start_producers: true,
        sasl: Keyword.get(@kafka_config, :sasl)
      )

    Supervisor.init([], strategy: :one_for_one)
  end

  def produce(%{facility_id: facility_id} = doc) do
    :ok =
      :brod.produce_sync(
        :brod_client,
        Keyword.get(@kafka_config, :topic),
        :hash,
        facility_id,
        Encoder.encode_map(:compacted_reading, doc)
      )
  rescue
    e -> {:error, e}
  end
end
