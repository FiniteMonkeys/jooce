defmodule Jooce.RpcConnection do
  use Connection
  require Logger
  import Supervisor.Spec

  @moduledoc false

  @initial_state      %{name: "Jooce", host: '127.0.0.1', port: 50000, opts: [], timeout: 5000, sock: nil, sup: nil, guid: nil, stream_conn: nil}
  @helo               <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x52, 0x50, 0x43, 0x00, 0x00, 0x00>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  # def start(%{sup: sup, name: name} = args) do
  #   Logger.debug "in Jooce.RpcConnection.start({sup, name})"
  #   Connection.start(__MODULE__, %{@initial_state | name: name, sup: sup}, name: __MODULE__)
  # end

  # def start(%{sup: sup} = args) do
  #   Logger.debug "in Jooce.RpcConnection.start({sup})"
  #   start(%{args | name: "Jooce"})
  # end

  def start_link(%{sup: sup, name: name}) do
    Logger.debug "in Jooce.RpcConnection.start_link({sup, name})"
    Connection.start_link(__MODULE__, %{@initial_state | name: name, sup: sup}, name: __MODULE__)
  end

  def start_link(%{sup: _} = args) do
    Logger.debug "in Jooce.RpcConnection.start_link({sup})"
    start_link(%{args | name: "Jooce"})
  end

  def stop(conn) do
    Connection.call(conn, :close)
  end

  # def guid(conn) do
  #   Connection.call(conn, :guid)
  # end

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

  # def send(conn, data) do
  #   Connection.call(conn, {:send, data})
  # end

  # def recv(conn, bytes, timeout \\ 3000) do
  #   Connection.call(conn, {:recv, bytes, timeout})
  # end

  def call_rpc(conn, service, procedure) do
    Connection.call(conn, {:call_rpc, service, procedure})
  end

  def call_rpc(conn, service, procedure, args) do
    Connection.call(conn, {:call_rpc, service, procedure, args})
  end

  ##
  ## callbacks
  ##

  def init(state) do
    Logger.debug "in Jooce.RpcConnection.init"
    {:connect, :init, %{state | sock: nil}}
  end

  def connect(_info, %{sock: nil} = state) do
    Logger.debug "in Jooce.RpcConnection.connect"
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

  def handle_info(:start_stream_connection, %{sup: sup, guid: guid} = state) do
    Logger.debug "in Jooce.RpcConnection.handle_info(:start_stream_connection) with guid"
    opts = [restart: :temporary, function: :start_link]
    spec = worker(Jooce.StreamConnection, [guid], opts)
    {:ok, stream_conn} = Supervisor.start_child(sup, spec)
    {:noreply, %{state | stream_conn: stream_conn}}
  end

  def handle_info(:start_stream_connection, state) do
    Logger.debug "in Jooce.RpcConnection.handle_info(:start_stream_connection) with guid"
    # connect hasn't returned yet?
    send(self(), :start_stream_connection)
    {:noreply, state}
  end

  def handle_call(_, _, %{sock: nil} = state) do
    :error_logger.format("Closing connection because sock is nil~n", [])
    {:reply, {:error, :closed}, state}
  end

  # def handle_call({:send, data}, _, %{sock: sock} = state) do
  #   case :gen_tcp.send(sock, data) do
  #     :ok ->
  #       {:reply, :ok, state}
  #     {:error, _} = error ->
  #       {:disconnect, error, error, state}
  #   end
  # end

  # def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = state) do
  #   case :gen_tcp.recv(sock, bytes, timeout) do
  #     {:ok, _} = ok ->
  #       {:reply, ok, state}
  #     {:error, :timeout} = timeout ->
  #       {:reply, timeout, state}
  #     {:error, _} = error ->
  #       {:disconnect, error, error, state}
  #   end
  # end

  def handle_call(:guid, _, %{guid: guid} = state) do
    {:reply, {:ok, guid}, state}
  end

  # def handle_call(:start_stream, _, state) do
  #   {:ok, stream_conn} = Jooce.StreamConnection.start_link(state.guid)
  #   {:reply, {:ok, stream_conn}, %{state | stream_conn: stream_conn}}
  # end

  def handle_call({:add_stream_listener, stream_id, pid}, _from, state) do
    Jooce.StreamConnection.add_stream_listener(state.stream_conn, stream_id, pid)
  end

  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end

  def handle_call({:call_rpc, service, procedure}, _, %{sock: sock} = state) do
    req = [service: service, procedure: procedure]
          |> Jooce.Protobuf.Request.new
          |> Jooce.Protobuf.Request.encode
    req_len = req |> String.length |> :gpb.encode_varint
    :gen_tcp.send(sock, req_len <> req)

    {resp_len, _} = sock |> read_varint |> :gpb.decode_varint
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

  def handle_call({:call_rpc, service, procedure, args}, _, %{sock: sock} = state) do
    req = [service: service, procedure: procedure, arguments: build_args(args)]
          |> Jooce.Protobuf.Request.new
          |> Jooce.Protobuf.Request.encode
    req_len = req |> String.length |> :gpb.encode_varint
    :gen_tcp.send(sock, req_len <> req)

    {resp_len, _} = sock |> read_varint |> :gpb.decode_varint
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

  def build_stream_request(service, procedure) do
    Jooce.Protobuf.Request.new(service: service, procedure: procedure)
  end

  def build_stream_request(service, procedure, args) do
    Jooce.Protobuf.Request.new(service: service, procedure: procedure, arguments: build_args(args))
  end

  def build_args(args) do
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
