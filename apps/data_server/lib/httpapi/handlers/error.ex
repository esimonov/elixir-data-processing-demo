defmodule DataServer.HTTPAPI.Handlers.Error do
  @moduledoc false

  import Plug.Conn

  def not_found(conn) do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
