defmodule DataServer.HTTPAPI.Router do
  use Plug.Router

  alias DataServer.HTTPAPI.Handlers.Error
  alias DataServer.HTTPAPI.Handlers.Sensor

  plug(:match)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/api/sensors/:facility_id" do
    Sensor.find(conn)
  end

  match _ do
    Error.not_found(conn)
  end
end
