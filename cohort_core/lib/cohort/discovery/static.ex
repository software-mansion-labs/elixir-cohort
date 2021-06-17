defmodule Cohort.Discovery.Static do
  @moduledoc """
  This module implements a simple registry of nodes, which is just a static list. 
  List of nodes can be passed upon initialization and cannot be modified later on.

  Internally it uses ETS for the storage so multiple processes can quickly query 
  the registry in a concurrent manner.
  """
  require Record
  use Cohort.Discovery

  Record.defrecord(:state, table_by_id: nil, table_by_tag: nil, table_all: nil)

  @table_by_id_name :cohort_discovery_simple_nodes_by_id
  @table_by_tag_name :cohort_discovery_simple_nodes_by_tag
  @table_all_name :cohort_discovery_simple_nodes_all
  @table_all_key :all

  @impl true
  def handle_init([]) do
    raise ArgumentError,
      message: """
      Failed to initialize Cohort.Discovery.Static module.

      You passed an empty list of nodes.
      """
  end

  def handle_init(nodes) do
    table_by_id = :ets.new(@table_by_id_name, [:set, :protected, read_concurrency: true])
    table_by_tag = :ets.new(@table_by_tag_name, [:bag, :protected, read_concurrency: true])

    # There's no function in ets that just retreives all values as a list
    # so just store them for a faster retreival.
    table_all = :ets.new(@table_all_name, [:set, :protected, read_concurrency: true])

    nodes
    |> Enum.each(fn node ->
      if not :ets.insert_new(table_by_id, {node.id, node}) do
        raise ArgumentError,
          message: """
          Failed to initialize Cohort.Discovery.Static module.

          It seems that your node identifier #{inspect(node.id)} is non-unique.

          The error happened while processing the following node: #{inspect(node)}.
          """
      end

      node.tags
      |> Enum.each(fn tag ->
        :ets.insert(table_by_tag, {tag, node})
      end)
    end)

    true = :ets.insert_new(table_all, {@table_all_key, nodes})

    {:ok, state(table_by_id: table_by_id, table_by_tag: table_by_tag, table_all: table_all)}
  end

  @impl true
  def handle_get_nodes(state(table_all: table_all)) do
    {:ok, :ets.lookup_element(table_all, @table_all_key, 2)}
  end

  @impl true
  def handle_get_nodes_by_tag(tag, state(table_by_tag: table_by_tag)) do
    try do
      {:ok, :ets.lookup_element(table_by_tag, tag, 2)}
    rescue
      ArgumentError ->
        {:ok, []}
    end
  end

  @impl true
  def handle_get_node_by_id(id, state(table_by_id: table_by_id)) do
    try do
      {:ok, :ets.lookup_element(table_by_id, id, 2)}
    rescue
      ArgumentError ->
        {:error, :unknown}
    end
  end
end
