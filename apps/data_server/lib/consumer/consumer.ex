defmodule DataServer.Consumer do
  @moduledoc """
  A consumer implemented using Broadway for processing messages from a message broker.

  This module:
  - Decodes Protobuf messages into domain-specific structs.
  - Inserts decoded data into the storage.
  """
  use Broadway

  alias DataServer.Storage

  alias DataServer.Consumer.Protobuf

  def start_link(_) do
    Broadway.start_link(__MODULE__, Application.get_env(:data_server, :broadway, %{}))
  end

  def handle_message(_, %Broadway.Message{data: data} = message, _context) do
    decoded =
      data
      |> Schema.CompactedReading.decode()
      |> decode_protobuf()

    Storage.insert_one(:compacted_reading, decoded)

    message
  end

  defp decode_protobuf(%Schema.CompactedReading{window: window} = doc) do
    doc
    |> Map.from_struct()
    |> Map.merge(%{window: Protobuf.from_protobuf_interval(window)})
  end
end
