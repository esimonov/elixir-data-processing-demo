defmodule DataServer.Behaviours.Storage do
  @moduledoc false

  @type document :: map()
  @type document_type :: atom()
  @type filter :: map()
  @type reason :: atom()
  @type details :: map()
  @type sensors :: [String.t()]
  @type sensor_stats :: [map()]
  @type total :: non_neg_integer()

  @callback insert_one(document_type, document) ::
              {:ok, document()}
              | {:error, reason, details}

  @callback find(document_type, filter) ::
              {:ok, [document()], total()}
              | {:error, reason, details}
  @callback find(document_type, filter, keyword()) ::
              {:ok, [document()], total()}
              | {:error, reason, details}

  @callback get_stats(document_type, sensors) :: {:ok, sensor_stats} | {:error, reason, details}
end
