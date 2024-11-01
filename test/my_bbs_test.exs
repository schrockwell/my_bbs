defmodule MyBBSTest do
  use ExUnit.Case
  doctest MyBBS

  test "greets the world" do
    assert MyBBS.hello() == :world
  end
end
