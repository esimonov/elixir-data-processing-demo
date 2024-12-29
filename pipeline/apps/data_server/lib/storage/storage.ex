defmodule DataServer.Storage do
  @moduledoc false

  @target Application.compile_env(:data_server, :storage)

  defdelegate insert_one(document, document_type), to: @target
end
