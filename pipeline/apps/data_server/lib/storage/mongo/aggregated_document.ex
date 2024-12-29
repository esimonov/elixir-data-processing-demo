defmodule Storage.Mongo.Window do
  use Mongo.Collection

  require Logger

  document do
    attribute(:start_time, DateTime.t())
    attribute(:end_time, DateTime.t())
  end
end

defmodule Storage.Mongo.AggregatedDocument do
  require Logger
  use Mongo.Collection

  @coll_name Application.compile_env(:data_server, :storage_collection_name)

  collection @coll_name do
    # The `dump` function will remove the attribute automatically before saving to the database.
    attribute(:id, String.t(), derived: true)
    attribute(:facility_id, String.t())
    attribute(:avg_humidity, float())
    attribute(:avg_temperature, float())
    attribute(:avg_pressure, float())
    attribute(:max_humidity, float())
    attribute(:max_temperature, float())
    attribute(:max_pressure, float())
    attribute(:min_humidity, float())
    attribute(:min_temperature, float())
    attribute(:min_pressure, float())
    embeds_one(:window, Storage.Mongo.Window, default: &Storage.Mongo.Window.new/0)
    attribute(:received_at, DateTime.t(), default: &DateTime.utc_now/0)

    after_load(&Storage.Mongo.AggregatedDocument.after_load/1)
  end

  def new(%{} = map) do
    new()
    |> Map.merge(map)
    |> after_load()
  end

  @spec after_load(Storage.Mongo.AggregatedDocument.t()) :: Storage.Mongo.AggregatedDocument.t()
  def after_load(%Storage.Mongo.AggregatedDocument{_id: id} = doc) do
    %Storage.Mongo.AggregatedDocument{doc | id: BSON.ObjectId.encode!(id)}
  end
end
