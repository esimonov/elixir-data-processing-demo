defmodule Schema.Helpers.Encoder do
  @moduledoc """
  Provides utility functions for encoding Elixir maps into Protobuf structs.
  """

  def encode_map(:compacted_reading, %{} = map) do
    struct(
      Schema.CompactedReading,
      Map.merge(
        map,
        %{window: to_protobuf_interval(map.window_start, map.window_end)}
      )
    )
    |> Schema.CompactedReading.encode()
  end

  def to_protobuf_interval(start_time, end_time) do
    %Schema.Interval{
      start_time: to_protobuf_timestamp(start_time),
      end_time: to_protobuf_timestamp(end_time)
    }
  end

  def to_protobuf_timestamp(datetime) do
    micros = elem(datetime.microsecond, 0)

    %Google.Protobuf.Timestamp{
      seconds: DateTime.to_unix(datetime),
      nanos: micros * 1_000
    }
  end
end
