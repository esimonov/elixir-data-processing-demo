defmodule DataServer.HTTPAPI.Handlers.Sensor do
  import Plug.Conn

  alias DataServer.HTTPAPI.Pagination

  alias DataServer.Storage

  def find(conn) do
    with {:ok, limit} <- Pagination.validate_limit(conn.params["limit"]),
         {:ok, offset} <- Pagination.validate_offset(conn.params["offset"]) do
      opts = [limit: limit, offset: offset]
      filter = %{facility_id: conn.params["facility_id"]}

      case(Storage.find(:compacted_reading, filter, opts)) do
        {:ok, readings, total} ->
          send_resp(
            conn,
            200,
            Jason.encode!(
              %{
                data: readings,
                pagination:
                  %Pagination{limit: limit, offset: offset, total: total}
                  |> Map.from_struct()
              },
              pretty: true
            )
          )

        {:error, _reason, _details} ->
          send_resp(conn, 404, Jason.encode!(%{error: "Resource not found"}))
      end
    else
      {:error, _} ->
        send_resp(conn, 500, Jason.encode!(%{error: "Internal server error"}))
    end
  end
end
