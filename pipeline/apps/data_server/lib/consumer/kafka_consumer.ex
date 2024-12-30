defmodule DataServer.KafkaConsumer do
  use Broadway

  alias DataServer.Storage

  def start_link(_) do
    Broadway.start_link(__MODULE__, Application.get_env(:data_server, :broadway, %{}))
  end

  def handle_message(_, %Broadway.Message{data: data} = message, _context) do
    data
    |> Schema.CompactedReading.decode()
    |> decode_protobuf()
    |> Storage.insert_one(:compacted_reading)

    message
  end

  defp decode_protobuf(%Schema.CompactedReading{window: window} = doc) do
    doc
    |> Map.from_struct()
    |> Map.merge(%{window: from_protobuf_interval(window)})
  end

  defp from_protobuf_interval(%Schema.Interval{start_time: start_time, end_time: end_time}) do
    %{
      start_time: from_protobuf_timestamp(start_time),
      end_time: from_protobuf_timestamp(end_time)
    }
  end

  defp from_protobuf_timestamp(%Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos}) do
    seconds
    |> DateTime.from_unix!()
    |> DateTime.add(div(nanos, 1_000), :microsecond)
  end
end
