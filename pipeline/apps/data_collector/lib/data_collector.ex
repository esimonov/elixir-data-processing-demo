defmodule DataCollector do
  use GenServer

  @moduledoc """
  Documentation for `DataCollector`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DataCollector.hello()
      :world

  """
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_args) do
    IO.puts("Data collector started")
    {:ok, self()}
  end
end
