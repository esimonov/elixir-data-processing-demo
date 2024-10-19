defmodule DataGenerator do
  use Application

  @moduledoc """
  Documentation for `DataGenerator`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DataGenerator.hello()
      :world

  """
  def start(_type, _args) do
    IO.puts("Data generator started")
    {:ok, self()}
  end
end
