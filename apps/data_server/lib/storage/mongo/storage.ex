defmodule DataServer.Storage.Mongo do
  @moduledoc """
  A module for interacting with MongoDB.

  Implements the `DataServer.Behaviours.Storage` behaviour.


  ## Options

  The module provides support for translating external options (e.g., `:offset`, `:start_time`) into the internal format.

  ## Error Handling

  All database errors are standardized into a `{:error, :database_error, reason}` tuple.
  """
  require Logger
  alias DataServer.Storage.Mongo.{CompactedReading, Repo}

  @behaviour DataServer.Behaviours.Storage

  @impl true
  def find(:compacted_reading, filter \\ %{}, opts \\ []) do
    with docs when is_list(docs) <- Repo.all(CompactedReading, filter, translate_opts(opts)),
         {:ok, total} <- Repo.count(CompactedReading, filter) do
      {:ok, Enum.map(docs, &process_document/1), total}
    else
      {:error, %{} = err} -> process_error(err)
    end
  end

  @impl true
  def get_stats(:compacted_reading, sensors) do
    pipeline = construct_stats_pipeline(sensors)

    case Mongo.aggregate(:mongo, CompactedReading.__collection__(:collection), pipeline) do
      %Mongo.Stream{} = stream -> {:ok, for(doc <- stream, do: doc)}
      {:error, %{} = err} -> process_error(err)
    end
  end

  @impl true
  def insert_one(:compacted_reading, reading) do
    Logger.debug("Inserting to database: #{inspect(reading)}")

    doc = CompactedReading.new(reading)

    case Repo.insert(doc) do
      {:ok, res} -> {:ok, res}
      {:error, %{} = err} -> process_error(err)
    end
  end

  defp translate_opts(opts), do: Enum.map(opts, &substitute_opt_names/1)

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

  defp construct_stats_pipeline(requested_field_names) do
    field_names = validate_stats_field_names(requested_field_names)

    group =
      Enum.reduce(
        field_names,
        [_id: "$facility_id"],
        fn name, acc ->
          [{:"stdev_#{name}", %{"$stdDevSamp": "$avg_#{name}"}} | acc]
        end
      )

    project =
      Enum.map(
        field_names,
        fn name -> {name, [stdev: "$stdev_#{name}"]} end
      )

    [
      %{"$group": group},
      %{"$project": project},
      %{"$sort": [_id: 1]}
    ]
  end

  @allowed_field_names ~w(humidity pressure temperature)

  defp validate_stats_field_names(values) do
    case Enum.filter(values, &(&1 in @allowed_field_names)) do
      [] -> @allowed_field_names
      filtered -> filtered
    end
  end

  defp process_document(doc) do
    doc
    |> CompactedReading.dump()
    |> CompactedReading.after_load()
  end

  defp process_error(%Mongo.Error{} = err),
    do: {:error, :database_error, Mongo.Error.message(err)}

  defp process_error(%Mongo.WriteError{} = err),
    do: {:error, :database_error, Mongo.WriteError.message(err)}

  defp process_error(err),
    do: {:error, :database_error, inspect(err)}
end
