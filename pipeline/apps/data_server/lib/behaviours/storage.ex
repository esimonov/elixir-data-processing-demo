defmodule DataServer.Behaviours.Storage do
  @type document :: map()
  @type document_type :: atom()
  @type reason :: atom()
  @type details :: map()

  @callback insert_one(document, document_type) ::
              {:ok, document()}
              | {:error, reason}
              | {:error, reason, details}
end
