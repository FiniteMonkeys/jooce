defmodule Jooce.Connection do
  use Supervisor
  require Logger

  @moduledoc """
  Documentation for Jooce.Connection.
  """

  ##
  ## API
  ##

  @doc """

  """
  def start_link(name \\ "Jooce") do
    Logger.debug "in #{__MODULE__}.start_link/1"
    Supervisor.start_link(__MODULE__, %{sup: nil, name: name}, [name: String.to_atom("Jooce.Connection(#{name})")])
  end

  ##
  ## callbacks
  ##

  @doc """

  """
  def init(args) do
    Logger.debug "in #{__MODULE__}.init/1"
    child_opts = [restart: :temporary, function: :start_link]
    children = [
      worker(Jooce.Connection.Rpc, [%{args | sup: self()}], child_opts)
      # don't start Jooce.Connection.Stream -- Rpc has to do that
    ]
    opts = [strategy: :rest_for_one, max_restarts: 5, max_seconds: 5]
    supervise(children, opts)
  end

  ##
  ## utility functions
  ##

  @doc """
  Reads a varint from a connection.
  """
  def read_varint(sock, buffer \\ <<>>) do
    case :gen_tcp.recv(sock, 1, 3000) do
      {:ok, <<1 :: size(1), _ :: bitstring>> = byte} ->
        read_varint(sock, buffer <> byte)
      {:ok, <<0 :: size(1), _ :: size(7)>> = byte} ->
        buffer <> byte
      {:error, :timeout} ->
        read_varint(sock, buffer)
      other ->
        Logger.warn("read_varint/2 got something else: #{inspect other}")
        buffer
    end
  end

end
