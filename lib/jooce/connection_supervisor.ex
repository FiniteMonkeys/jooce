defmodule Jooce.ConnectionSupervisor do
  use Supervisor
  require Logger

  @moduledoc false

  ##
  ## API
  ##

  def start_link(args) do
    Logger.debug "in Jooce.ConnectionSupervisor.start_link(args)"
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_link do
    Logger.debug "in Jooce.ConnectionSupervisor.start_link"
    start_link(%{sup: nil, name: "Jooce"})
  end

  ##
  ## callbacks
  ##

  def init(args) do
    Logger.debug "in Jooce.ConnectionSupervisor.init"
    child_opts = [restart: :permanent, function: :start_link]
    children = [worker(Jooce.RpcConnection, [%{args | sup: self()}], child_opts)]
    opts = [strategy: :rest_for_one, max_restarts: 5, max_seconds: 5]
    supervise(children, opts)
  end
end
