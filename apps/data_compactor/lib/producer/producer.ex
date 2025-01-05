defmodule DataCompactor.Producer do
  @moduledoc false

  @target Application.compile_env(:data_compactor, :producer)

  defdelegate produce(document), to: @target
end
