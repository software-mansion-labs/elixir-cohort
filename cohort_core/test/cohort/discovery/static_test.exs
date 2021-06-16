defmodule Cohort.Discovery.StaticTest do
  use ExUnit.Case
  alias Cohort.Discovery.Static

  @valid_nodes [
    %Cohort.Node{
      id: "localhost1",
      transport: {
        Cohort.Transport.Gun,
        "ws://localhost:8001"
      },
      tags: []
    },
    %Cohort.Node{
      id: "localhost2",
      transport: {
        Cohort.Transport.Gun,
        "ws://localhost:8002"
      },
      tags: [:a, :b]
    },
    %Cohort.Node{
      id: "localhost3",
      transport: {
        Cohort.Transport.Gun,
        "ws://localhost:8003"
      },
      tags: [:b]
    }
  ]

  test "init/1 fails to initialize and raises an argument error if an empty list of nodes is given" do
    assert_raise ArgumentError, fn -> Static.init([]) end
  end

  test "init/1 suceeds to initialze if a non-empty list of nodes is given" do
    assert match?({:ok, _state}, Static.init(@valid_nodes))
  end

  test "get_node_by_id/2 returns a node if given ID was present during initialization" do
    {:ok, state} = Static.init(@valid_nodes)

    id = "localhost2"
    expected_node = @valid_nodes |> Enum.find(fn node -> node.id == id end)

    assert {:ok, expected_node} == Static.get_node_by_id(id, state)
  end

  test "get_node_by_id/2 returns an error if given ID was not present during initialization" do
    {:ok, state} = Static.init(@valid_nodes)

    assert {:error, :unknown} == Static.get_node_by_id("localhostXXX", state)
  end

  test "get_nodes/1 returns list of all nodes passed during initialization" do
    {:ok, state} = Static.init(@valid_nodes)

    assert {:ok, @valid_nodes} == Static.get_nodes(state)
  end

  test "get_nodes_by_tag/1 returns list of nodes with matching tags out of nodes passed during initialization" do
    {:ok, state} = Static.init(@valid_nodes)

    tag = :b
    expected_nodes = @valid_nodes |> Enum.filter(fn node -> Enum.member?(node.tags, tag) end)

    assert {:ok, expected_nodes} == Static.get_nodes_by_tag(tag, state)
  end

  test "get_nodes_by_tag/1 returns an empty list if no tags matches nodes passed during initialization" do
    {:ok, state} = Static.init(@valid_nodes)

    tag = :xxx

    assert {:ok, []} == Static.get_nodes_by_tag(tag, state)
  end
end
