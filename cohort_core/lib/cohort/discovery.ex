defmodule Cohort.Discovery do
  @compile {:inline, read_module: 0, read_state: 0}

  @table_name :cohort_discovery_state
  @table_state_key :state 
  @table_module_key :module 

  @type state_t :: any

  @doc """
  Initializes the discovery module using given arguments, which might
  be application-specific.

  The initialization does not have to start any processes. For simple
  discovery modules, such as `Cohort.Discovery.Static` it might be
  unnecessary overhead to perform message passing to query them.
  """
  @callback handle_init(any) :: 
    {:ok, state_t} |
    {:error, any}

  @doc """
  Returns all nodes known in the system.

  If no nodes with given tag are known it will still return `{:ok, []}`.

  It will return `{:error, reason}` only if retreival of the node list
  failed for some reason.
  """
  @callback handle_get_nodes(state_t) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}

  @doc """
  Returns all nodes known in the system with given tag.

  If no nodes with given tag are known it will still return `{:ok, []}`.

  It will return `{:error, reason}` only if retreival of the node list
  failed for some reason.
  """
  @callback handle_get_nodes_by_tag(Cohort.Node.tag_t(), state_t) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}

  @doc """
  Returns a node with a particular identifier.

  In node with given identifier is known it will return `{:ok, node}`.

  If no node with such identifier is known it will return `{:error, :unknown}`.

  If other error happened if retreival of the node list failed it will return
  `{:error, reason}` where `reason` is related to the underlying retreival failure.
  """
  @callback handle_get_node_by_id(Cohort.Node.id_t(), state_t) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}


  @doc false
  def init() do
    case Application.get_env(:cohort_core, :discovery) do
      nil ->
        raise """
        Unable to start Cohort due to the invalid configuration.

        It seems that configuration for node discovery is missing.

        Please ensure that you have the following keys in your config:

        config :cohort_core,
          discovery: {discovery_module, discovery_options}
        """

      {module, options} ->
        case module.handle_init(options) do
          {:ok, state} ->
            :ets.new(@table_name, [:set, :protected, :named_table, read_concurrency: true])
            true = :ets.insert_new(@table_name, {@table_module_key, module})
            true = :ets.insert_new(@table_name, {@table_state_key, state})

          {:error, reason} ->
            raise """
            Unable to start Cohort due to the error returned by the node discovery
            module 
            
              #{inspect(module)}
              
            The passed options were 

              #{inspect(options)}

            The error returned was 
            
              #{inspect(reason)}
            """
        end
    end
  end

  @spec get_nodes() ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}
  def get_nodes() do
    read_module().handle_get_nodes(read_state())
  end

  @spec get_nodes_by_tag(Cohort.Node.tag_t()) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}
  def get_nodes_by_tag(tag) do
    read_module().handle_get_nodes_by_tag(tag, read_state())
  end

  @spec get_node_by_id(Cohort.Node.id_t()) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}
  def get_node_by_id(id) do
    read_module().handle_get_node_by_id(id, read_state())
  end

  defp read_module() do
    :ets.lookup_element(@table_name, @table_module_key, 2)
  end

  defp read_state() do
    :ets.lookup_element(@table_name, @table_state_key, 2)
  end

  defmacro __using__(_) do
    quote do
      @behaviour Cohort.Discovery
    end
  end
end
