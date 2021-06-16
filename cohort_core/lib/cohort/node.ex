defmodule Cohort.Node do
  @moduledoc """
  Cohort.Node represents a single computing node that can belong to any
  cohort. Typically that will be just a single VM process.

  Each Node has several mandatory attributes:

  * id - an unique identifier which is going to be used accross the system,
  * transport - a transport module or tuple of `{transport_module, transport_options}`
    which can be used to connect to the particular node.

  Optionally it can have some extra attributes:

  * tag - a list of terms that can be later used to filter out the nodes.
  """

  # FIXME?
  @type id_t :: any
  @type tag_t :: any

  @type t :: %__MODULE__{
          id: any,
          transport: module | {module, any},
          tags: [tag_t]
        }

  defstruct id: nil,
            transport: nil,
            tags: []
end
