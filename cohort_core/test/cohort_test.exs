defmodule CohortTest do
  use ExUnit.Case
  doctest Cohort

  test "greets the world" do
    assert Cohort.hello() == :world
  end
end
