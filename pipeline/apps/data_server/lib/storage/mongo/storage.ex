defmodule DataServer.Storage.Mongo do
  alias Storage.Mongo.AggregatedDocument

  alias DataServer.Storage.Mongo.Repo

  @behaviour DataServer.Behaviours.Storage

  def find(:aggregated_document, filter \\ %{}) do
    case Repo.all(AggregatedDocument, filter) do
      {:error, %{} = err} ->
        process_error(err)

      res ->
        {:ok,
         for(doc <- res, do: doc |> AggregatedDocument.dump() |> AggregatedDocument.after_load())}
    end
  end

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
    do: {:error, :mongo_write_error, reason}

  defp process_error(%{} = err),
    do: {:error, :unknown_mongo_error, err}
end
