defmodule DataServer.Consumer do
  @moduledoc """
  A consumer implemented using Broadway for processing messages from a message broker.

  This module:
  - Decodes Protobuf messages into domain-specific structs.
  - Inserts decoded data into the storage.
  """
  use Broadway

  require Logger

  alias DataServer.Storage

  alias Schema.Helpers.Decoder

  def start_link(_) do
    Broadway.start_link(__MODULE__, Application.get_env(:data_server, :broadway, %{}))
  end

  def handle_message(_, %Broadway.Message{data: data} = message, _context) do
    with decoded_struct <- Schema.CompactedReading.decode(data),
         {:ok, decoded_map} <- Decoder.decode_map(decoded_struct),
         {:ok, _} <- Storage.insert_one(:compacted_reading, decoded_map) do
      message
    else
      {:error, :invalid_data, details} ->
        Logger.error("Invalid protobuf data: #{details}")

      {:error, :database_error, details} ->
        Logger.error("Database error: #{details}")
    end

    message
  end
end
