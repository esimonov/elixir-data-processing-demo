defmodule DataServer.HTTPAPI.Pagination do
  defstruct [:limit, :offset, :total]

  def validate_limit(limit, opts \\ []) do
    opts = Keyword.merge([default_limit: 10, max_limit: 20], opts)

    default_limit = Keyword.fetch!(opts, :default_limit)

    max_limit = Keyword.fetch!(opts, :max_limit)

    do_validate_limit(limit, default_limit, max_limit)
  end

  defp do_validate_limit(nil, default_limit, max_limit), do: {:ok, min(default_limit, max_limit)}

  defp do_validate_limit(limit, default_limit, max_limit)
       when is_binary(limit) do
    case Integer.parse(limit) do
      {0, ""} -> {:ok, default_limit}
      {value, ""} when value > 0 -> {:ok, min(value, max_limit)}
      _ -> {:error, "Invalid limit: must be a positive integer"}
    end
  end

  defp do_validate_limit(_, _, _), do: {:error, "Invalid limit: must be a non-negative integer"}

  def validate_offset(nil), do: {:ok, 0}

  def validate_offset(offset) when is_binary(offset) do
    case Integer.parse(offset) do
      {value, ""} when value >= 0 -> {:ok, value}
      _ -> {:error, "Invalid offset: must be a non-negative integer"}
    end
  end

  def validate_offset(_), do: {:error, "Invalid offset: must be a non-negative integer"}
end
