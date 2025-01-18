defmodule ConcurrentApp.Application do
  @moduledoc """
  Application entry point with supervision tree.
  """

  use Application

  alias Plug.Cowboy

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Task.Supervisor},
      {ConcurrentApp.DB, []},
      {Cowboy, scheme: :http, plug: ConcurrentApp.Router, options: [port: 4000, transport_options: [max_connections: 500_000]]}
    ]

    opts = [strategy: :one_for_one, name: ConcurrentApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
