defmodule DataServer.Storage.Mongo do
  alias Storage.Mongo.CompactedReading

  alias DataServer.Storage.Mongo.Repo

  @behaviour DataServer.Behaviours.Storage

  def find(:compacted_reading, filter \\ %{}, opts \\ []) do
    with docs <- Repo.all(CompactedReading, filter, map_opts(opts)),
         {:ok, total} <- Repo.count(CompactedReading, filter) do
      {
        :ok,
        for(
          doc <- docs,
          do:
            doc
            |> CompactedReading.dump()
            |> CompactedReading.after_load()
        ),
        total
      }
    else
      {:error, %{} = err} ->
        process_error(err)
    end
  end

  def insert_one(map, :compacted_reading) do
    IO.puts("Saving to Database! #{inspect(map)}")

    doc = CompactedReading.new(map)

    case Repo.insert(doc) do
      {:ok, res} -> {:ok, res}
      {:error, %{} = err} -> process_error(err)
    end
  end

  defp process_error(%{write_errors: reason}),
    do: {:error, :mongo_write_error, reason}

  defp process_error(%{} = err),
    do: {:error, :unknown_mongo_error, err}

  defp map_opts(opts) do
    with offset <- opts[:offset] do
      opts
      |> Keyword.delete(:offset)
      |> Keyword.put(:skip, offset)
    end
  end
end
