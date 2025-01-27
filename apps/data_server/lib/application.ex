defmodule DataServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias DataServer.Storage.Mongo.Repo

  @impl true
  def start(_type, _args) do
    children = [
      {Mongo, Repo.config()},
      DataServer.Consumer.Supervisor,
      {
        Plug.Cowboy,
        scheme: :http,
        plug: DataServer.HTTPAPI.Router,
        options: [port: Application.get_env(:data_server, :http_server_port)]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DataServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
