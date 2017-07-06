defmodule Jooce.Client do
  use GenServer
  require Logger

  @moduledoc """
  Documentation for Jooce.Client.
  """

  ##
  ## public API
  ##

  @doc """
  Simple ping test on the GenServer.
  """
  def ping do
    Logger.debug "in #{__MODULE__}.ping"
    GenServer.call(__MODULE__, :ping)
  end

  @doc """
  Connect to the Jooce client. Each connection should have a unique name.
  """
  def connect(name) do
    Logger.debug "in #{__MODULE__}.connect/1"
    GenServer.call(__MODULE__, {:connect, name})
  end

  @doc """
  Ping test the connection.
  """
  def ping_connection(conn) do
    Logger.debug "in #{__MODULE__}.ping_connection/1"
    Jooce.Connection.Rpc.ping(conn)
  end

  @doc """

  """
  def call_rpc(conn, service, procedure) do
    Logger.debug "in #{__MODULE__}.call_rpc/3"
    Jooce.Connection.Rpc.call_rpc(conn, service, procedure)
  end

  def call_rpc(conn, service, procedure, args) do
    Logger.debug "in #{__MODULE__}.call_rpc/3"
    Jooce.Connection.Rpc.call_rpc(conn, service, procedure, args)
  end

  # @doc """
  # Add a streaming request and return its identifier.
  # """
  def add_stream(conn, service, procedure) do
    Logger.debug "in #{__MODULE__}.add_stream/3"
    call_rpc(conn, "KRPC", "AddStream", [{Jooce.Connection.build_stream_request(service, procedure), {:module, Jooce.Protobuf.Request}, nil}])
  end

  def add_stream(conn, service, procedure, args) do
    Logger.debug "in #{__MODULE__}.add_stream/4"
    call_rpc(conn, "KRPC", "AddStream", [{Jooce.Connection.build_stream_request(service, procedure, args), {:module, Jooce.Protobuf.Request}, nil}])
  end

  ##
  ## internal API
  ##

  @doc """

  """
  def start_link(state, opts \\ []) do
    Logger.debug "in #{__MODULE__}.start_link/2"
    GenServer.start_link(__MODULE__, state, opts)
  end

  ##
  ## callbacks
  ##

  @doc """

  """
  def handle_call(:ping, _from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:ping)"
    {:reply, :pong, state}
  end

  @doc """

  """
  def handle_call({:connect, name}, _from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:connect, name)"
    import Supervisor.Spec, warn: false

    opts = [restart: :temporary, function: :start_link, name: name]
    spec = supervisor(Jooce.Connection, [name], opts)
    {:ok, conn_sup_pid} = Supervisor.start_child(Jooce, spec)

    # TODO: maybe have a separate GenServer which is the interface to the RPC and stream connections?

    conn = (name |> rpc_connection)
    {:reply, {:ok, conn}, Map.put(state, name, conn_sup_pid)}
  end

  ##
  ## private functions
  ##

  @doc """

  """
  defp rpc_connection(name) do
    Logger.debug "in #{__MODULE__}.rpc_connection/1"
    [{conn,_}|_] = Registry.lookup(Jooce.Registry, "RPC(#{name})")
    conn
  end
end
