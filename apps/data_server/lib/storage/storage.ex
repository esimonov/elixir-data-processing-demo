defmodule DataServer.Storage do
  @moduledoc false

  @target Application.compile_env(:data_server, :storage)

  defdelegate find(document_type, filter), to: @target
  defdelegate insert_one(document, document_type), to: @target
end
