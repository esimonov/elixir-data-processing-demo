defmodule DataServer.Consumer.Protobuf do
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
