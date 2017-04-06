defmodule Jooce.StreamConnection do
  use Connection
  require Logger

  @moduledoc false

  @initial_state      %{host: '127.0.0.1', port: 50001, opts: [], timeout: 5000, sock: nil, guid: nil}
  @helo               <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x53, 0x54, 0x52, 0x45, 0x41, 0x4D>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  def start(guid) do
    Connection.start(__MODULE__, %{@initial_state | guid: guid}, name: __MODULE__)
  end

  def start_link(guid) do
    Logger.debug "in Jooce.StreamConnection.start_link"
    Connection.start_link(__MODULE__, %{@initial_state | guid: guid}, name: __MODULE__)
  end

  def stop(conn) do
    Connection.call(conn, :close)
  end

  def add_stream_listener(conn, stream_id, pid) do
    Connection.call(conn, {:add_stream_listener, stream_id, pid})
  end

  ##
  ## callbacks
  ##

  def init(state) do
    Logger.debug "in Jooce.StreamConnection.init"
    {:connect, :init, %{state | sock: nil}}
  end

  def connect(_info, %{sock: nil} = state) do
    Logger.debug "in Jooce.StreamConnection.connect"
    case :gen_tcp.connect(state.host, state.port, [:binary, {:active, false}, {:packet, :raw}] ++ state.opts, state.timeout) do
      {:ok, sock} ->

        ## handshake stuff goes here
        :ok = :gen_tcp.send(sock, @helo)
        <<packet::binary-size(16), _::binary>> = state.guid <> @thirty_two_zeros
        :ok = :gen_tcp.send(sock, packet)
        {:ok, <<0x4F, 0x4B>>} = :gen_tcp.recv(sock, 2, 10000)
        # end handshake stuff

        {:ok, %{state | sock: sock}}
      {:error, reason} ->
        :error_logger.format("Connection error: ~s~n", [:inet.format_error(reason)])
        {:backoff, 1000, state}
    end
  end

  def disconnect(info, %{sock: sock} = state) do
    :ok = :gen_tcp.close(sock)
    case info do
      {:close, from} ->
        Connection.reply(from, :ok)
      {:error, :closed} ->
        :error_logger.format("Connection closed~n", [])
      {:error, reason} ->
        :error_logger.format("Connection error: ~s~n", [:inet.format_error(reason)])
    end
    {:stop, :normal, %{state | sock: nil}}
  end

  def handle_call(_, _, %{sock: nil} = state) do
    :error_logger.format("Closing connection because sock is nil~n", [])
    {:reply, {:error, :closed}, state}
  end

  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end

  def handle_call({:add_stream_listener, _stream_id, _pid}, _from, state) do
    ## set up a loop
    ##   when something comes in for it, send to pid
    {:reply, :ok, state}
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
      ## handle timeout explicitly -- close connection, crash process?
      _ ->
        buffer
    end
  end
end
