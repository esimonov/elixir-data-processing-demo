defmodule DataServer.Behaviours.Storage do
  @type document :: map()
  @type document_type :: atom()
  @type filter :: map()
  @type reason :: atom()
  @type details :: map()
  @type total :: non_neg_integer()

  @callback insert_one(document, document_type) ::
              {:ok, document()}
              | {:error, reason}
              | {:error, reason, details}

  @callback find(document_type, filter) ::
              {:ok, [document()], total()}
              | {:error, reason}
              | {:error, reason, details}
end
