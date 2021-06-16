defmodule Cohort.Discovery do
  @doc """
  Initializes the discovery module using given arguments, which might
  be application-specific.

  The initialization does not have to start any processes. For simple
  discovery modules, such as `Cohort.Discovery.Static` it might be
  unnecessary overhead to perform message passing to query them.
  """
  @callback init(any) :: {:ok, any}

  @doc """
  Returns all nodes known in the system.

  If no nodes with given tag are known it will still return `{:ok, []}`.

  It will return `{:error, reason}` only if retreival of the node list
  failed for some reason.
  """
  @callback get_nodes(any) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}

  @doc """
  Returns all nodes known in the system with given tag.

  If no nodes with given tag are known it will still return `{:ok, []}`.

  It will return `{:error, reason}` only if retreival of the node list
  failed for some reason.
  """
  @callback get_nodes_by_tag(Cohort.Node.tag_t(), any) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}

  @doc """
  Returns a node with a particular identifier.

  In node with given identifier is known it will return `{:ok, node}`.

  If no node with such identifier is known it will return `{:error, :unknown}`.

  If other error happened if retreival of the node list failed it will return
  `{:error, reason}` where `reason` is related to the underlying retreival failure.
  """
  @callback get_node_by_id(Cohort.Node.id_t(), any) ::
              {:ok, [Cohort.Node.t()]}
              | {:error, any}

  defmacro __using__(_) do
    quote do
      @behaviour Cohort.Discovery
    end
  end
end
