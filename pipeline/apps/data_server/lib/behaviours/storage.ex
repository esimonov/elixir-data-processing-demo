defmodule DataServer.Behaviours.Storage do
  @type document :: map()
  @type reason :: atom()
  @type details :: map()

  @callback insert(document) ::
              {:ok, document()}
              | {:error, reason}
              | {:error, reason, details}
end
