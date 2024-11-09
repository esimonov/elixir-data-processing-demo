defmodule DataServer.Storage.Mongo do
  @behaviour DataServer.Behaviours.Storage

  def insert(document) do
    IO.puts("Saving to Database! #{inspect(document)}")

    {:ok, document}
  end
end
