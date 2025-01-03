defmodule DataServer.Consumer.Protobuf do
  def decode_map(%Schema.CompactedReading{window: window} = doc) do
    doc
    |> Map.from_struct()
    |> Map.merge(%{window: from_protobuf_interval(window)})
  end

  def from_protobuf_interval(%Schema.Interval{start_time: start_time, end_time: end_time}) do
    %{
      start_time: from_protobuf_timestamp(start_time),
      end_time: from_protobuf_timestamp(end_time)
    }
  end

  def from_protobuf_timestamp(%Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos}) do
    seconds
    |> DateTime.from_unix!()
    |> DateTime.add(div(nanos, 1_000), :microsecond)
  end
end
