defmodule DataServer.HTTPAPI.Helpers do
  def validate_limit(limit, default_limit \\ 10, max_limit \\ 20)

  def validate_limit(limit, default_limit, max_limit)
      when is_binary(limit) do
    case Integer.parse(limit) do
      {0, ""} -> {:ok, default_limit}
      {value, ""} when value > 0 -> {:ok, min(value, max_limit)}
      _ -> {:error, "Invalid limit: must be a positive integer"}
    end
  end

  def validate_limit(_, _, _), do: {:error, "Invalid limit: must be a non-negative integer"}

  def validate_offset(offset) when is_binary(offset) do
    case Integer.parse(offset) do
      {value, ""} when value >= 0 -> {:ok, value}
      _ -> {:error, "Invalid offset: must be a non-negative integer"}
    end
  end

  def validate_offset(_), do: {:error, "Invalid offset: must be a non-negative integer"}
end
