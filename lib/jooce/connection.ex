defmodule Jooce.Connection do
  use Supervisor
  require Logger

  @moduledoc false

  ##
  ## API
  ##

  def start_link(name \\ "Jooce") do
    Logger.debug "in #{__MODULE__}.start_link(#{name})"
    Supervisor.start_link(__MODULE__, %{sup: nil, name: name}, [name: String.to_atom("Jooce.Connection(#{name})")])
  end

  ##
  ## callbacks
  ##

  def init(args) do
    Logger.debug "in #{__MODULE__}.init"
    child_opts = [restart: :temporary, function: :start_link]
    children = [
      worker(Jooce.Connection.Rpc, [%{args | sup: self()}], child_opts)
      # don't start Jooce.Connection.Stream -- Rpc has to do that
    ]
    opts = [strategy: :rest_for_one, max_restarts: 5, max_seconds: 5]
    supervise(children, opts)
  end
end
