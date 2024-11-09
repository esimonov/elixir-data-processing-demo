defmodule DataCollector.KafkaProducer do
  @moduledoc """
  Module responsible for producing messages to Kafka.
  """

  use Supervisor

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

  def produce_aggregated_document(%{:facility_id => facility_id} = doc) do
    doc
    |> encode_protobuf()
    |> produce_message(facility_id, Keyword.get(@kafka_config, :topic))
  end

  def produce_message(message, key, topic_name) do
    try do
      :ok =
        :brod.produce_sync(
          :brod_client,
          topic_name,
          :hash,
          key,
          message
        )
    rescue
      e -> {:error, e}
    end
  end

  defp encode_protobuf(%{} = doc) do
    struct(
      Schema.AggregatedDocument,
      Map.merge(doc, %{window: to_protobuf_interval(doc.window_start, doc.window_end)})
    )
    |> Schema.AggregatedDocument.encode()
  end

  defp to_protobuf_interval(start_time, end_time) do
    %Schema.Interval{
      start_time: to_protobuf_timestamp(start_time),
      end_time: to_protobuf_timestamp(end_time)
    }
  end

  defp to_protobuf_timestamp(datetime) do
    micros = elem(datetime.microsecond, 0)

    %Google.Protobuf.Timestamp{
      seconds: DateTime.to_unix(datetime),
      nanos: micros * 1_000
    }
  end
end
