defmodule DataServer.Storage.Mongo do
  alias Storage.Mongo.AggregatedDocument

  alias DataServer.Storage.Mongo.Repo

  @behaviour DataServer.Behaviours.Storage

  def insert_one(map, :aggregated_document) do
    IO.puts("Saving to Database! #{inspect(map)}")

    doc = AggregatedDocument.new(map)

    case Repo.insert(doc) do
      {:ok, res} ->
        {:ok, res}

      {:error, %{} = err} ->
        process_error(err)
    end
  end

  defp process_error(%{write_errors: reason}),
    do: {:error, :mongo_write_error, Enum.join(reason, ";")}

  defp process_error(%{} = err),
    do: {:error, :unknown_mongo_error, inspect(err)}
end
