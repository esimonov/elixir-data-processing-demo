defmodule DataGeneratorTest do
  use ExUnit.Case
  doctest DataGenerator

  test "greets the world" do
    assert DataGenerator.hello() == :world
  end
end
