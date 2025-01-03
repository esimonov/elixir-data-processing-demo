defmodule DataServer.Consumer.Protobuf do
  def decode_map(%Schema.CompactedReading{window: window} = doc) do
    case from_protobuf_interval(window) do
      {:ok, interval} ->
        map =
          doc
          |> Map.from_struct()
          |> Map.merge(%{window: interval})

        {:ok, map}

      error ->
        error
    end
  end

  def decode_map(data), do: {:error, :invalid_data, inspect(data, limit: 10)}

  def from_protobuf_interval(%Schema.Interval{start_time: start_time, end_time: end_time}) do
    with {:ok, start_time_dt} <- from_protobuf_timestamp(start_time),
         {:ok, end_time_dt} <- from_protobuf_timestamp(end_time) do
      {:ok, %{start_time: start_time_dt, end_time: end_time_dt}}
    else
      error -> error
    end
  end

  def from_protobuf_interval(data), do: {:error, :invalid_data, inspect(data, limit: 10)}

  def from_protobuf_timestamp(%Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos}) do
    case DateTime.from_unix(seconds) do
      {:ok, dt} -> {:ok, DateTime.add(dt, div(nanos, 1_000), :microsecond)}
      {:error, reason} -> {:error, :invalid_data, inspect(reason)}
    end
  end

  def from_protobuf_timestamp(data), do: {:error, :invalid_data, inspect(data, limit: 10)}
end
