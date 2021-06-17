defmodule Cohort.Sample.Balancer do
  use Cohort.Balancer

  @impl true
  def handle_init(_options) do
    {:ok, nil}
  end

  @impl true 
  def handle_select_cohort_leader_node(_cohort_id, _state) do
    # TODO use smarter balancer
    {:ok, nodes} = Cohort.Discovery.get_nodes()
    {:ok, hd(nodes)}
  end
end