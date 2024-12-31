defmodule DataServer.HTTPAPI.Handlers.Sensor do
  import Plug.Conn

  import DataServer.HTTPAPI.Helpers, only: [validate_limit: 1, validate_offset: 1]

  alias DataServer.Storage

  def find(conn) do
    with {:ok, limit} <- validate_limit(conn.params["limit"]),
         {:ok, offset} <- validate_offset(conn.params["offset"]),
         opts <- [limit: limit, offset: offset],
         filter <- %{facility_id: conn.params["facility_id"]} do
      case(Storage.find(:compacted_reading, filter, opts)) do
        {:ok, resource} ->
          send_resp(conn, 200, Jason.encode!(resource, pretty: true))

        {:error, _reason, _details} ->
          send_resp(conn, 404, Jason.encode!(%{error: "Resource not found"}))
      end
    else
      {:error, _} ->
        send_resp(conn, 500, Jason.encode!(%{error: "Internal server error"}))
    end
  end
end
