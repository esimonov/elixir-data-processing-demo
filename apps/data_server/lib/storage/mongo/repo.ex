defmodule DataServer.Storage.Mongo.Repo do
  require Logger

  use Mongo.Repo,
    otp_app: :data_server,
    topology: :mongo
end
