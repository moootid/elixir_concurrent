defmodule ConcurrentAppTest do
  use ExUnit.Case
  doctest ConcurrentApp

  test "greets the world" do
    assert ConcurrentApp.hello() == :world
  end
end
