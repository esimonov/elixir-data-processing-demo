defmodule DataServer.HTTPAPI.Server do
  use Plug.Router

  alias DataServer.Storage

  plug(:match)

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/api/sensors/:facility_id" do
    case Storage.find(
           :compacted_reading,
           %{
             facility_id: conn.params["facility_id"]
           }
         ) do
      {:ok, resource} ->
        send_resp(conn, 200, Jason.encode!(resource, pretty: true))

      {:error, _reason, _details} ->
        send_resp(conn, 404, Jason.encode!(%{error: "Resource not found"}))
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
