defmodule Jooce.Connection.Stream do
  use Connection
  require Logger

  @moduledoc false

  @initial_state      %{host: '127.0.0.1', port: 50001, opts: [], timeout: 5000, sock: nil, guid: nil}
  @helo               <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x53, 0x54, 0x52, 0x45, 0x41, 0x4D>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  # @doc ~S"""
  #
  # """
  def start_link(guid, name) do
    Logger.debug "in #{__MODULE__}.start_link/2"
    Connection.start_link(__MODULE__, %{@initial_state | guid: guid}, [name: String.to_atom("Stream(#{name})")])
  end

  # @doc ~S"""
  #
  # """
  def stop(conn) do
    Logger.debug "in #{__MODULE__}.stop/1"
    Connection.call(conn, :close)
  end

  # def add_stream_listener(conn, stream_id, pid) do
  #   Connection.call(conn, {:add_stream_listener, stream_id, pid})
  # end

  ##
  ## callbacks
  ##

  # @doc ~S"""
  #
  # """
  def init(state) do
    Logger.debug "in #{__MODULE__}.init/1"
    {:connect, :init, %{state | sock: nil}}
  end

  # @doc ~S"""
  #
  # """
  def connect(_info, %{sock: nil} = state) do
    Logger.debug "in #{__MODULE__}.connect/2"
    case :gen_tcp.connect(state.host, state.port, [:binary, {:active, false}, {:packet, :raw}] ++ state.opts, state.timeout) do
      {:ok, sock} ->

        ## handshake stuff goes here
        :ok = :gen_tcp.send(sock, @helo)
        <<packet::binary-size(16), _::binary>> = state.guid <> @thirty_two_zeros
        :ok = :gen_tcp.send(sock, packet)
        {:ok, <<0x4F, 0x4B>>} = :gen_tcp.recv(sock, 2, 10000)
        # end handshake stuff

        ## set up process to listen to sock
        spawn(fn -> receive_loop(sock) end)

        {:ok, %{state | sock: sock}}
      {:error, reason} ->
        :error_logger.format("Connection error: ~s~n", [:inet.format_error(reason)])
        {:backoff, 1000, state}
    end
  end

  # @doc ~S"""
  #
  # """
  def receive_loop(sock) do
    Logger.debug "in #{__MODULE__}.receive_loop/1"
    try do
      {resp_len, _} = sock |> Jooce.Connection.read_varint |> :gpb.decode_varint
      case :gen_tcp.recv(sock, resp_len, 3000) do
        {:ok, resp} ->
          response = Jooce.Protobuf.Response.decode(resp)
          cond do
            response.has_error ->
              # {:reply, {:error, response.error, response.time}, state}
              Logger.error "reply has_error: #{inspect response.error}"
            response.has_return_value ->
              # {:reply, {:ok, response.return_value, response.time}, state}
              Logger.error "reply has_return_value: #{inspect response.return_value}"
            true ->
              # {:reply, {:ok, nil, response.time}, state}
              Logger.debug "reply :ok"
          end
        other ->
          Logger.error "got #{inspect other} instead"
      end
    rescue
      e in FunctionClauseError ->
        Logger.error "FunctionClauseError: #{inspect e}"
    end
    receive_loop(sock)
  end

  # @doc ~S"""
  #
  # """
  def disconnect(info, %{sock: sock} = state) do
    Logger.debug "in #{__MODULE__}.disconnect/2"
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

  # @doc ~S"""
  #
  # """
  def handle_call(_, _, %{sock: nil} = state) do
    :error_logger.format("Closing connection because sock is nil~n", [])
    {:reply, {:error, :closed}, state}
  end

  # @doc ~S"""
  #
  # """
  def handle_call(:close, from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:close)"
    {:disconnect, {:close, from}, state}
  end

  # def handle_call({:add_stream_listener, _stream_id, _pid}, _from, state) do
  #   ## set up a loop
  #   ##   when something comes in for it, send to pid
  #   {:reply, :ok, state}
  # end
end
