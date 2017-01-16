defmodule Jooce.Client do
  use Connection

  @initial_state      %{host: '127.0.0.1', port: 50000, opts: [], timeout: 5000, sock: nil, guid: nil}
  @rpc_helo           <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x52, 0x50, 0x43, 0x00, 0x00, 0x00>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  def start_link do
    Connection.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def guid(conn) do
    Connection.call(conn, :guid)
  end

  ## low-level API

  def send(conn, data) do
    Connection.call(conn, {:send, data})
  end

  def recv(conn, bytes, timeout \\ 3000) do
    Connection.call(conn, {:recv, bytes, timeout})
  end

  def close(conn) do
    Connection.call(conn, :close)
  end

  ##
  ## callbacks
  ##

  def init(state) do
    {:connect, :init, %{state | sock: nil}}
  end

  def connect(_info, %{sock: nil} = state) do
    case :gen_tcp.connect(state.host, state.port, [:binary, {:active, false}, {:packet, :raw}] ++ state.opts, state.timeout) do
      {:ok, sock} ->
        ## handshake stuff goes here
        :ok = :gen_tcp.send(sock, @rpc_helo)
        <<packet::binary-size(32), _::binary>> = "Jooce" <> @thirty_two_zeros
        :ok = :gen_tcp.send(sock, packet)
        {:ok, guid} = :gen_tcp.recv(sock, 16, 10000)
        # end handshake stuff

        {:ok, %{state | sock: sock, guid: guid}}
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
    {:connect, :reconnect, %{state | sock: nil}}
  end

  def handle_call(_, _, %{sock: nil} = state) do
    :error_logger.format("Closing connection because sock is nil~n", [])
    {:reply, {:error, :closed}, state}
  end

  def handle_call({:send, data}, _, %{sock: sock} = state) do
    case :gen_tcp.send(sock, data) do
      :ok ->
        {:reply, :ok, state}
      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end

  def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, bytes, timeout) do
      {:ok, _} = ok ->
        {:reply, ok, state}
      {:error, :timeout} = timeout ->
        {:reply, timeout, state}
      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end

  def handle_call(:guid, _, %{guid: guid} = state) do
    {:reply, {:ok, guid}, state}
  end

  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end
end
