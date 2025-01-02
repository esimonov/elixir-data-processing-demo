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

    do_validate_limit(limit, default_limit, max_limit)
  end

  defp do_validate_limit(limit, default_limit, max_limit) when limit in [nil, ""],
    do: {:ok, min(default_limit, max_limit)}

  defp do_validate_limit(limit, default_limit, max_limit)
       when is_binary(limit) do
    case Integer.parse(limit) do
      {0, ""} -> {:ok, default_limit}
      {value, ""} when value > 0 -> {:ok, min(value, max_limit)}
      _ -> {:error, "Invalid limit: must be a positive integer"}
    end
  end

  defp do_validate_limit(_, _, _), do: {:error, "Invalid limit: must be a non-negative integer"}

  def validate_offset(offset) when offset in [nil, ""], do: {:ok, 0}

  @doc """
  Validates and normalizes the `offset` parameter.

  ## Parameters

  - `offset` - The raw `offset` value from query parameters.

  ## Returns

  - `{:ok, offset}` - If the `offset` is valid and normalized.
  - `{:error, reason}` - If the `offset` is invalid.
  """
  def validate_offset(offset) when is_binary(offset) do
    case Integer.parse(offset) do
      {value, ""} when value >= 0 -> {:ok, value}
      _ -> {:error, "Invalid offset: must be a non-negative integer"}
    end
  end

  def validate_offset(_), do: {:error, "Invalid offset: must be a non-negative integer"}
end
