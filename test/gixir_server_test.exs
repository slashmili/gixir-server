defmodule GixirServerTest do
  use ExUnit.Case
  doctest GixirServer

  test "greets the world" do
    assert GixirServer.hello() == :world
  end
end
