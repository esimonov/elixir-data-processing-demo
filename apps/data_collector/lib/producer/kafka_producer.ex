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

  def produce(%{facility_id: facility_id} = doc) do
    :ok =
      :brod.produce_sync(
        :brod_client,
        Keyword.get(@kafka_config, :topic),
        :hash,
        facility_id,
        encode_protobuf(doc)
      )
  rescue
    e -> {:error, e}
  end

  defp encode_protobuf(%{} = doc) do
    struct(
      Schema.CompactedReading,
      Map.merge(
        doc,
        %{window: to_protobuf_interval(doc.window_start, doc.window_end)}
      )
    )
    |> Schema.CompactedReading.encode()
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
