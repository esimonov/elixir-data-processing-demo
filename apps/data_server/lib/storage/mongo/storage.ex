defmodule DataServer.Storage.Mongo do
  alias Storage.Mongo.CompactedReading

  alias DataServer.Storage.Mongo.Repo

  @behaviour DataServer.Behaviours.Storage

  def find(:compacted_reading, filter \\ %{}, opts \\ []) do
    with docs when not is_tuple(docs) <-
           Repo.all(CompactedReading, filter, dbg(translate_opts(opts))),
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

  defp translate_opts(opts) do
    Enum.map(opts, &substitute_opt_names/1)
  end

  @name_substitutions %{
    offset: :skip,
    start_time: :"window.start_time"
  }

  defp substitute_opt_names({external_name, [value]}) do
    {k, v} = substitute_opt_names(value)

    {external_name, Keyword.from_keys([k], v)}
  end

  defp substitute_opt_names({external_name, value}) do
    name = Map.get(@name_substitutions, external_name, external_name)

    {name, value}
  end

  defp process_error(%Mongo.Error{message: message}),
    do: {:error, :database_error, message}

  defp process_error(%{write_errors: reason}),
    do: {:error, :database_error, reason}

  defp process_error(%{} = err),
    do: {:error, :database_error, err}
end
