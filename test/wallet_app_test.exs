defmodule WalletAppTest do
  use ExUnit.Case
  doctest WalletApp

  test "greets the world" do
    assert WalletApp.hello() == :world
  end
end
