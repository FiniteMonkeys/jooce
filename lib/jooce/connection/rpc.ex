defmodule Jooce.Connection.Rpc do
  use Connection
  require Logger

  @moduledoc false

  @initial_state      %{name: "Jooce", host: '127.0.0.1', port: 50000, opts: [], timeout: 5000, sock: nil, sup: nil, guid: nil, stream_conn: nil}
  @helo               <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x52, 0x50, 0x43, 0x00, 0x00, 0x00>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  # @doc ~S"""
  #
  # """
  def start_link(%{sup: sup, name: name}) do
    Logger.debug "in #{__MODULE__}.start_link({sup, name})"
    connection_name = {:via, Registry, {Jooce.Registry, "RPC(#{name})"}}
    Connection.start_link(__MODULE__, %{@initial_state | name: name, sup: sup}, [name: connection_name])
  end

  # @doc ~S"""
  #
  # """
  def start_link(%{sup: _} = args) do
    Logger.debug "in #{__MODULE__}.start_link({sup})"
    start_link(%{args | name: "Jooce"})
  end

  # @doc ~S"""
  #
  # """
  def stop(conn) do
    Logger.debug "in #{__MODULE__}.stop/1"
    Connection.call(conn, :close)
  end

  # @doc ~S"""
  #
  # """
  def ping(conn) do
    Logger.debug "in #{__MODULE__}.ping/1"
    Connection.call(conn, :ping)
  end

  # @doc ~S"""
  # Add a streaming request and return its identifier.
  #
  # ## RPC signature
  # AddStream(KRPC.Request request) : uint32
  # """
  # def add_stream(conn, service, procedure) do
  #   {:ok, stream_id, time} = Connection.call(conn, {:call_rpc, "KRPC", "AddStream", [{build_stream_request(service, procedure), {:module, Jooce.Protobuf.Request}, nil}]})
  #   # call into StreamConnection
  #   {:ok, stream_id, time}
  # end

  # def add_stream(conn, service, procedure, args) do
  #   {:ok, stream_id, time} = Connection.call(conn, {:call_rpc, "KRPC", "AddStream", [{build_stream_request(service, procedure, args), {:module, Jooce.Protobuf.Request}, nil}]})
  #   # call into StreamConnection
  #   {:ok, stream_id, time}
  # end

  # def add_stream_listener(conn, stream_id, pid) do
  #   Connection.call(conn, {:add_stream_listener, stream_id, pid})
  # end

  # @doc ~S"""
  # Remove a streaming request.
  #
  # ## RPC signature
  # RemoveStream(uint32 id)
  # """
  # def remove_stream(conn, id) do
  #   Connection.call(conn, {:call_rpc, "KRPC", "RemoveStream", [id]})
  # end

  # @doc ~S"""
  #
  # """
  def call_rpc(conn, service, procedure) do
    Logger.debug "in #{__MODULE__}.call_rpc/3"
    Connection.call(conn, {:call_rpc, service, procedure})
  end

  # @doc ~S"""
  #
  # """
  def call_rpc(conn, service, procedure, args) do
    Logger.debug "in #{__MODULE__}.call_rpc/4"
    Connection.call(conn, {:call_rpc, service, procedure, args})
  end

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
        <<packet::binary-size(32), _::binary>> = state.name <> @thirty_two_zeros
        :ok = :gen_tcp.send(sock, packet)
        {:ok, guid} = :gen_tcp.recv(sock, 16, 10000)
        # end handshake stuff

        send(self(), :start_stream_connection)

        {:ok, %{state | sock: sock, guid: guid}}
      {:error, reason} ->
        :error_logger.format("Connection error: ~s~n", [:inet.format_error(reason)])
        {:backoff, 1000, state}
    end
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
  def handle_info(:start_stream_connection, %{sup: sup, name: name, guid: guid} = state) do
    import Supervisor.Spec, warn: false
    Logger.debug "in #{__MODULE__}.handle_info(:start_stream_connection) with guid"
    opts = [restart: :temporary, function: :start_link]
    spec = worker(Jooce.Connection.Stream, [guid, name], opts)
    {:ok, stream_conn} = Supervisor.start_child(sup, spec)
    {:noreply, %{state | stream_conn: stream_conn}}
  end

  # @doc ~S"""
  #
  # """
  def handle_info(:start_stream_connection, state) do
    Logger.debug "in #{__MODULE__}.handle_info(:start_stream_connection) without guid"
    # connect hasn't returned yet?
    send(self(), :start_stream_connection)
    {:noreply, state}
  end

  # @doc ~S"""
  #
  # """
  def handle_call(_, _, %{sock: nil} = state) do
    Logger.error "Closing connection because sock is nil"
    {:reply, {:error, :closed}, state}
  end

  # @doc ~S"""
  #
  # """
  def handle_call(:ping, _from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:ping)"
    {:reply, :pong, state}
  end

  # def handle_call(:start_stream, _, state) do
  #   {:ok, stream_conn} = Jooce.StreamConnection.start_link(state.guid)
  #   {:reply, {:ok, stream_conn}, %{state | stream_conn: stream_conn}}
  # end

  # def handle_call({:add_stream_listener, stream_id, pid}, _from, state) do
  #   Jooce.StreamConnection.add_stream_listener(state.stream_conn, stream_id, pid)
  # end

  # @doc ~S"""
  #
  # """
  def handle_call(:close, from, state) do
    Logger.debug "in #{__MODULE__}.handle_call(:disconnect)"
    {:disconnect, {:close, from}, state}
  end

  # @doc ~S"""
  #
  # """
  def handle_call({:call_rpc, service, procedure}, _, %{sock: sock} = state) do
    Logger.debug "in #{__MODULE__}.handle_call({:call_rpc, service, procedure})"
    req = [service: service, procedure: procedure]
          |> Jooce.Protobuf.Request.new
          |> Jooce.Protobuf.Request.encode
    req_len = req |> String.length |> :gpb.encode_varint
    :gen_tcp.send(sock, req_len <> req)

    {resp_len, _} = sock |> Jooce.Connection.read_varint |> :gpb.decode_varint
    {:ok, resp} = :gen_tcp.recv(sock, resp_len, 3000)

    response = Jooce.Protobuf.Response.decode(resp)
    cond do
      response.has_error ->
        {:reply, {:error, response.error, response.time}, state}
      response.has_return_value ->
        {:reply, {:ok, response.return_value, response.time}, state}
      true ->
        {:reply, {:ok, nil, response.time}, state}
    end
  end

  # @doc ~S"""
  #
  # """
  def handle_call({:call_rpc, service, procedure, args}, _, %{sock: sock} = state) do
    Logger.debug "in #{__MODULE__}.handle_call({:call_rpc, service, procedure, args})"
    req = [service: service, procedure: procedure, arguments: build_args(args)]
          |> Jooce.Protobuf.Request.new
          |> Jooce.Protobuf.Request.encode
    req_len = req |> String.length |> :gpb.encode_varint
    :gen_tcp.send(sock, req_len <> req)

    {resp_len, _} = sock |> Jooce.Connection.read_varint |> :gpb.decode_varint
    {:ok, resp} = :gen_tcp.recv(sock, resp_len, 3000)

    response = Jooce.Protobuf.Response.decode(resp)
    cond do
      response.has_error ->
        {:reply, {:error, response.error, response.time}, state}
      response.has_return_value ->
        {:reply, {:ok, response.return_value, response.time}, state}
      true ->
        {:reply, {:ok, nil, response.time}, state}
    end
  end

  ##
  ## utility functions
  ##

  # @doc ~S"""
  #
  # """
  def build_stream_request(service, procedure) do
    Logger.debug "in #{__MODULE__}.build_stream_request/2"
    Jooce.Protobuf.Request.new(service: service, procedure: procedure)
  end

  # @doc ~S"""
  #
  # """
  def build_stream_request(service, procedure, args) do
    Logger.debug "in #{__MODULE__}.build_stream_request/3"
    Jooce.Protobuf.Request.new(service: service, procedure: procedure, arguments: build_args(args))
  end

  # @doc ~S"""
  #
  # """
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
end
