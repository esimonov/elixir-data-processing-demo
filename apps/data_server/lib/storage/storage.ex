defmodule DataServer.Storage do
  @moduledoc false

  @target Application.compile_env(:data_server, :storage)

  defdelegate find(document_type, filter, opts \\ []), to: @target
  defdelegate get_stats(document_type, opts \\ []), to: @target
  defdelegate insert_one(document_type, document), to: @target
end
