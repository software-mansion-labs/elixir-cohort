defmodule Cohort.Transport.GunTest do
  use ExUnit.Case
  doctest Cohort.Transport.Gun

  test "greets the world" do
    assert Cohort.Transport.Gun.hello() == :world
  end
end
