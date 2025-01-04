defmodule DataServer.HTTPAPI.Handlers.Sensor do
  @moduledoc """
  The module provides HTTP request handlers for managing and querying sensor data.
  """
  require Logger

  import DataServer.HTTPAPI.JSON

  alias DataServer.HTTPAPI.Pagination

  alias DataServer.Storage

  def find(conn) do
    with {:ok, limit} <- Pagination.validate_limit(conn.params["limit"]),
         {:ok, offset} <- Pagination.validate_offset(conn.params["offset"]) do
      opts = [limit: limit, offset: offset, sort: [start_time: -1]]
      filter = %{facility_id: conn.params["facility_id"]}

      case(Storage.find(:compacted_reading, filter, opts)) do
        {:ok, readings, total} ->
          send_json_with_pagination(
            conn,
            readings,
            %Pagination{
              limit: limit,
              offset: offset,
              total: total
            }
          )

        {:error, :database_error, details} ->
          send_internal_server_error(conn, details)
      end
    else
      {:error, :validation_error, details} ->
        send_bad_request(conn, details)
    end
  end

  def get_stats(conn) do
    sensors =
      conn.params
      |> Map.get("sensors", "")
      |> String.split(",", trim: true)
      |> Enum.reject(&(&1 == ""))

    case Storage.get_stats(:compacted_reading, sensors) do
      {:ok, stats} ->
        send_json(conn, stats)

      {:error, :database_error, details} ->
        send_internal_server_error(conn, details)
    end
  end
end
