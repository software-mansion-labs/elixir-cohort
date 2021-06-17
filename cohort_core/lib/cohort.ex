defmodule Cohort do
  @doc false
  def init() do
    Cohort.Discovery.init()
    Cohort.Balancer.init()
  end
end
