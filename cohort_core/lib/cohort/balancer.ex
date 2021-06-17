defmodule Cohort.Balancer do
  @type cohort_id_t :: any # FIXME
  @type state_t :: any

  @compile {:inline, read_module: 0, read_state: 0}

  @table_name :cohort_balancer_state
  @table_state_key :state 
  @table_module_key :module 

  @doc """
  Initializes the balancer module using given arguments, which might
  be application-specific.

  The initialization does not have to start any processes. For simple
  balancer modules, such as `Cohort.Discovery.Static` it might be
  unnecessary overhead to perform message passing to query them.
  """
  @callback handle_init(any) :: 
    {:ok, state_t} |
    {:error, any}

  @doc """
  Callback which has to be a deterministic function which returns a node for
  a given cohort identifier. In other words, for given cohort identifier it
  should always return the same node.

  It is being called if there's an attempt to join a certain cohort. Cohort's 
  state can be held on any node in the system, and such a node is called
  a cohort leader. There must be a way for any other node to determine which 
  node is a cohort leader, potentially without necessity to query all nodes
  or rely on some sort of shared or distributed state.

  Please remind that this function might be called frequently on many nodes
  and in parallel.

  There might be several approaches to implement such a function.

  One approach is to use a hash function, which has a benefit of being able
  to map cohort identifier to a node quickly, and without necessity to 
  synchronize this effort between nodes.

  Another approach might be to keep a shared state (which can be any sort
  of database) which stores the mappings, but that can become a bottleneck
  or single point of failure and needs to handle parallelism well.
  """
  @callback handle_select_cohort_leader_node(cohort_id_t, state_t) :: 
    {:ok, Cohort.Node.t} |
    {:error, any}

  @doc false
  def init() do
    case Application.get_env(:cohort_core, :balancer) do
      nil ->
        raise """
        Unable to start Cohort due to the invalid configuration.

        It seems that configuration for balancer is missing.

        Please ensure that you have the following keys in your config:

        config :cohort_core,
          balancer: {balancer_module, discovery_options}
        """

      {module, options} ->
        case module.handle_init(options) do
          {:ok, state} ->
            :ets.new(@table_name, [:set, :protected, :named_table, read_concurrency: true])
            true = :ets.insert_new(@table_name, {@table_module_key, module})
            true = :ets.insert_new(@table_name, {@table_state_key, state})

          {:error, reason} ->
            raise """
            Unable to start Cohort due to the error returned by the balancer
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

  @spec select_cohort_leader_node(cohort_id_t) :: 
    {:ok, Cohort.Node.t} |
    {:error, any}
  def select_cohort_leader_node(cohort_id) do
    read_module().handle_select_cohort_leader_node(cohort_id, read_state())
  end

  defp read_module() do
    :ets.lookup_element(@table_name, @table_module_key, 2)
  end

  defp read_state() do
    :ets.lookup_element(@table_name, @table_state_key, 2)
  end

  defmacro __using__(_) do
    quote do
      @behaviour Cohort.Balancer
    end
  end
end