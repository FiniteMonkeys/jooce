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

  """
  def build_stream_request(service, procedure) do
    Logger.debug "in #{__MODULE__}.build_stream_request/2"
    Jooce.Protobuf.Request.new(service: service, procedure: procedure)
  end

  @doc """

  """
  def build_stream_request(service, procedure, args) do
    Logger.debug "in #{__MODULE__}.build_stream_request/3"
    Jooce.Protobuf.Request.new(service: service, procedure: procedure, arguments: build_args(args))
  end

  @doc """

  """
  def build_args(args) do
    Logger.debug "in #{__MODULE__}.build_args/1"
    new_args = for {arg, i} <- Enum.with_index(args), into: [] do
                 case arg do
                   {value, {:module, module}, _msg_defs} ->
                     Jooce.Protobuf.Argument.new(position: i, value: apply(module, :encode, [value]))
                   {value, type, msg_defs} ->
                     Jooce.Protobuf.Argument.new(position: i, value: :gpb.encode_value(value, type, msg_defs))
                   _ ->
                     nil
                 end
               end
    Enum.reject(new_args, fn(x) -> x == nil end)
  end

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
