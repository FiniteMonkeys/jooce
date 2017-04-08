defmodule Jooce.Client do
  use GenServer
  require Logger

  @moduledoc false

  ##
  ## API
  ##

  def start_link(state, opts \\ []) do
    Logger.debug "in #{__MODULE__}.start_link"
    GenServer.start_link(__MODULE__, state, opts)
  end

  def ping do
    Logger.debug "in #{__MODULE__}.ping"
    GenServer.call(__MODULE__, :ping)
  end

  def connect(name) do
    Logger.debug "in #{__MODULE__}.connect"
    GenServer.call(__MODULE__, {:connect, name})
  end

  ##
  ## callbacks
  ##

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call({:connect, name}, _from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:connect, name)"
    import Supervisor.Spec, warn: false

    opts = [restart: :temporary, function: :start_link, name: name]
    spec = supervisor(Jooce.Connection, [name], opts)
    {:ok, conn_sup_pid} = Supervisor.start_child(Jooce, spec)

    {:reply, {:ok, conn_sup_pid}, Map.put(state, name, conn_sup_pid)}
  end
end
