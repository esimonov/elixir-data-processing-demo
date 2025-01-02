defmodule DataServer.Storage.Mongo.Window do
  use Mongo.Collection

  require Logger

  document do
    attribute(:start_time, DateTime.t())
    attribute(:end_time, DateTime.t())
  end
end

defmodule DataServer.Storage.Mongo.CompactedReading do
  require Logger
  use Mongo.Collection

  alias DataServer.Storage.Mongo.{CompactedReading, Window}

  @coll_name Application.compile_env(:data_server, :compacted_readings_coll_name)

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
    embeds_one(:window, Window, default: &Window.new/0)
    attribute(:received_at, DateTime.t(), default: &DateTime.utc_now/0)

    after_load(&CompactedReading.after_load/1)
    before_dump(&CompactedReading.before_dump/1)
  end

  def new(%{} = map) do
    new()
    |> Map.merge(map)
    |> after_load()
  end

  def after_load(%CompactedReading{_id: id} = doc),
    do: %CompactedReading{doc | id: BSON.ObjectId.encode!(id)}

  def after_load(%{} = doc), do: Map.drop(doc, ["_id"])

  def before_dump(%CompactedReading{} = doc), do: %CompactedReading{doc | id: nil}
end
