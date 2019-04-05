defmodule AudioTest do
  use ExUnit.Case
  doctest Audio

  test "greets the world" do
    assert Audio.hello() == :world
  end
end
