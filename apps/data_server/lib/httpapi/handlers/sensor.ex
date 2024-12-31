defmodule DataServer.HTTPAPI.Handlers.Sensor do
  import Plug.Conn

  alias DataServer.Storage

  def find(conn) do
    facility_id = conn.params["facility_id"]

    case Storage.find(:compacted_reading, %{facility_id: facility_id}) do
      {:ok, resource} ->
        send_resp(conn, 200, Jason.encode!(resource, pretty: true))

      {:error, _reason, _details} ->
        send_resp(conn, 404, Jason.encode!(%{error: "Resource not found"}))
    end
  end
end
