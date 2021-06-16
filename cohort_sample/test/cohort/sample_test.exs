defmodule Cohort.SampleTest do
  use ExUnit.Case
  doctest Cohort.Sample

  test "greets the world" do
    assert Cohort.Sample.hello() == :world
  end
end
