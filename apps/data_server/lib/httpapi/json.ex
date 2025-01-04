defmodule DataServer.HTTPAPI.JSON do
  @moduledoc """
  Helper function for JSON responses.
  """
  alias DataServer.HTTPAPI.Pagination

  import Plug.Conn

  require Logger

  def send_json(conn, json) do
    send_resp(
      conn,
      200,
      Jason.encode!(
        json,
        pretty: true
      )
    )
  end

  def send_json_with_pagination(conn, docs, %Pagination{} = pagination) when is_list(docs) do
    send_json(
      conn,
      %{
        data: docs,
        pagination: Map.from_struct(pagination)
      }
    )
  end

  def send_bad_request(conn, msg) when is_binary(msg) do
    Logger.error("Bad request: #{msg}")

    send_resp(conn, 400, Jason.encode!(%{error: msg}))
  end

  def send_internal_server_error(conn, details) do
    Logger.error("Internal server error: #{inspect(details)}")

    send_resp(conn, 500, Jason.encode!(%{error: "Internal server error"}))
  end
end
