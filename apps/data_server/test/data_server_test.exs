defmodule DataServerTest do
  use ExUnit.Case
  doctest DataServer

  test "greets the world" do
    assert DataServer.hello() == :world
  end
end
