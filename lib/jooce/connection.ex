defmodule Jooce.Connection do
  use Connection

  @moduledoc false

  @initial_state      %{name: "Jooce", host: '127.0.0.1', rpc_port: 50000, stream_port: 50001, opts: [], timeout: 5_000, sock: nil, guid: nil}
  @rpc_helo           <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x52, 0x50, 0x43, 0x00, 0x00, 0x00>>
  @stream_helo        <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x53, 0x54, 0x52, 0x45, 0x41, 0x4D>>
  @thirty_two_zeros   String.duplicate(<<0>>, 32)

  ##
  ## API
  ##

  def start(name \\ "Jooce") do
    Connection.start(__MODULE__, %{@initial_state | name: name}, name: __MODULE__)
  end

  def start_link(name \\ "Jooce") do
    Connection.start_link(__MODULE__, %{@initial_state | name: name}, name: __MODULE__)
  end

  def stop(conn) do
    Connection.call(conn, :close)
  end

  def guid(conn) do
    Connection.call(conn, :guid)
  end

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
    {:connect, :init, %{state | sock: nil}}
  end

  def connect(_info, %{sock: nil} = state) do
    case :gen_tcp.connect(state.host, state.rpc_port, [:binary, {:active, false}, {:packet, :raw}] ++ state.opts, state.timeout) do
      {:ok, sock} ->

        ## handshake stuff goes here
        :ok = :gen_tcp.send(sock, @rpc_helo)
        <<packet::binary-size(32), _::binary>> = state.name <> @thirty_two_zeros
        :ok = :gen_tcp.send(sock, packet)
        {:ok, guid} = :gen_tcp.recv(sock, 16, 10_000)
        # end handshake stuff

        {:ok, %{state | sock: sock, guid: guid}}
      {:error, reason} ->
        :error_logger.format("Connection error: ~s~n", [:inet.format_error(reason)])
        {:backoff, 1_000, state}
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
    {:ok, resp} = :gen_tcp.recv(sock, resp_len, 3_000)

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
    {:ok, resp} = :gen_tcp.recv(sock, resp_len, 3_000)

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
    case :gen_tcp.recv(sock, 1, 3_000) do
      {:ok, <<1 :: size(1), _ :: bitstring>> = byte} ->
        read_varint(sock, buffer <> byte)
      {:ok, <<0 :: size(1), _ :: size(7)>> = byte} ->
        buffer <> byte
      _ ->
        buffer
    end
  end

  def build_args(args) do
    new_args = for {arg, i} <- Enum.with_index(args), into: [] do
                 cond do
                   {value, type, msg_defs} = arg ->
                     Jooce.Protobuf.Argument.new(position: i, value: :gpb.encode_value(value, type, msg_defs))
                   true ->
                     nil
                 end
               end
    Enum.reject(new_args, fn(x) -> x == nil end)
  end
end
