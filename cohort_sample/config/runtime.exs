import Config

config :cohort_sample, Cohort,
  discovery: {
    Cohort.Discovery.Static,
    [
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
      },
    ]
  }
