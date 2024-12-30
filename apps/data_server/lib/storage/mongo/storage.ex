defmodule DataServer.Storage.Mongo do
  alias Storage.Mongo.CompactedReading

  alias DataServer.Storage.Mongo.Repo

  @behaviour DataServer.Behaviours.Storage

  def find(:compacted_reading, filter \\ %{}) do
    case Repo.all(CompactedReading, filter) do
      {:error, %{} = err} ->
        process_error(err)

      res ->
        {
          :ok,
          for(
            doc <- res,
            do:
              doc
              |> CompactedReading.dump()
              |> CompactedReading.after_load()
          )
        }
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
end
