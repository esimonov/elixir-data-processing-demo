defmodule DataServer.HTTPAPI.Pagination do
  @moduledoc """

  A module for handling pagination parameters in HTTP APIs.

  This module provides functions to validate and normalize `limit` and `offset` parameters
  used in paginated API endpoints. Defaults and maximum values for `limit` can be customized.

  ## Struct

  The `Pagination` struct contains the following fields:

  - `:limit` - The maximum number of items to return (default: `10`).
  - `:offset` - The starting index for items to return (default: `0`).
  - `:total` - The total number of items available.
  """

  @default_limit 10
  @max_limit 20

  @validation_error_template "Invalid %{param}: must be a non-negative integer; got '%{value}'"

  defstruct [:limit, :offset, :total]

  @doc """
  Validates and normalizes the `limit` parameter.

  ## Parameters

  - `limit` - The raw `limit` value from query parameters.
  - `opts` - Keyword list with:
    - `:default_limit` - Default limit to use if none is provided (default: `10`).
    - `:max_limit` - Maximum limit allowed (default: `20`).

  ## Returns

  - `{:ok, limit}` - If the `limit` is valid and normalized.
  - `{:error, reason}` - If the `limit` is invalid.

  """
  def validate_limit(limit, opts \\ []) do
    opts = Keyword.merge([default_limit: @default_limit, max_limit: @max_limit], opts)

    default_limit = Keyword.fetch!(opts, :default_limit)

    max_limit = Keyword.fetch!(opts, :max_limit)

    validate_param(limit, "limit", default_limit, max_limit)
  end

  @doc """
  Validates and normalizes the `offset` parameter.

  ## Parameters

  - `offset` - The raw `offset` value from query parameters.

  ## Returns

  - `{:ok, offset}` - If the `offset` is valid and normalized.
  - `{:error, reason}` - If the `offset` is invalid.
  """
  def validate_offset(offset), do: validate_param(offset, "offset", 0)

  defp validate_param(param, param_name, default_value, max_value \\ nil) do
    cond do
      param in [nil, ""] ->
        {:ok, min(default_value, max_value)}

      is_binary(param) ->
        case Integer.parse(param) do
          {0, ""} -> {:ok, min(default_value, max_value)}
          {value, ""} when value > 0 -> {:ok, min(value, max_value)}
          _ -> format_error(param_name, param)
        end

      true ->
        format_error(param_name, param)
    end
  end

  defp format_error(param_name, param) do
    {
      :error,
      :validation_error,
      @validation_error_template
      |> String.replace("%{param}", param_name)
      |> String.replace("%{value}", param)
    }
  end
end
