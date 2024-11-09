defmodule DataServer.Storage do
  @moduledoc false

  @target Application.compile_env(:data_server, :storage)

  defdelegate insert(document), to: @target
end
