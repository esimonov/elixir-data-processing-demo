defmodule DataCompactor.Behaviours.Producer do
  @moduledoc false

  @type document :: map()

  @callback produce(document) :: {:ok, document()} | {:error, String.t()}
end
