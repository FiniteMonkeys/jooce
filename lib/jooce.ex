defmodule Jooce do
  @moduledoc """
  Documentation for Jooce.
  """

  @doc ~S"""
  Open a connection to a kRPC server.
  """
  def start do
    Jooce.Connection.start
  end

  @doc ~S"""
  Open a connection to a kRPC server and links it to the current process.
  """
  def start_link do
    Jooce.Connection.start_link
  end

  @doc ~S"""
  Close a connection to a kRPC server.
  """
  def stop(conn) do
    Jooce.Connection.stop(conn)
  end

  @doc ~S"""
  Returns status information about the server.

  ## Reference

  https://krpc.github.io/krpc/communication-protocol.html#getstatus

  ## Examples

      iex> Jooce.get_status
      %Jooce.Protobuf.Status{
        adaptive_rate_control: true,
        blocking_recv: true,
        bytes_read: 1440,
        bytes_read_rate: 0.0,
        bytes_written: 1160,
        bytes_written_rate: 0.0,
        exec_time_per_rpc_update: 0.0,
        max_time_per_update: 10000,
        one_rpc_per_update: false,
        poll_time_per_rpc_update: 0.0010014179861173034,
        recv_timeout: 1000,
        rpc_rate: 0.0,
        rpcs_executed: 13,
        stream_rpc_rate: 0.0,
        stream_rpcs: 0,
        stream_rpcs_executed: 0,
        time_per_rpc_update: 0.0010170749155804515,
        time_per_stream_update: 1.2727523426292464e-6,
        version: "0.3.6"
      }

  """
  def get_status do
    {:ok, conn} = Jooce.Connection.start
    status = get_status(conn)
    Jooce.Connection.stop(conn)
    status
  end

  def get_status(conn) do
    req = Jooce.Protobuf.Request.new(service: "KRPC", procedure: "GetStatus")
          |> Jooce.Protobuf.Request.encode
    req_len = String.length(req) |> :gpb.encode_varint

    Jooce.Connection.send(conn, req_len <> req)

    {resp_len, _} = Jooce.Utils.read_varint(conn) |> :gpb.decode_varint
    {:ok, resp} = Jooce.Connection.recv(conn, resp_len)
    (resp |> Jooce.Protobuf.Response.decode).return_value |> Jooce.Protobuf.Status.decode
  end

  @doc ~S"""
  Returns status information about the server.

  ## Reference

  https://krpc.github.io/krpc/communication-protocol.html#getservices

  ## Examples

      iex> Jooce.get_services

  """
  def get_services do
    {:ok, conn} = Jooce.Connection.start
    services = get_services(conn)
    Jooce.Connection.stop(conn)
    services
  end

  def get_services(conn) do
    req = Jooce.Protobuf.Request.new(service: "KRPC", procedure: "GetServices")
          |> Jooce.Protobuf.Request.encode
    req_len = String.length(req) |> :gpb.encode_varint

    Jooce.Connection.send(conn, req_len <> req)

    {resp_len, _} = Jooce.Utils.read_varint(conn) |> :gpb.decode_varint
    {:ok, resp} = Jooce.Connection.recv(conn, resp_len)
    # IO.puts inspect (resp |> Jooce.Protobuf.Response.decode).return_value |> Jooce.Protobuf.Services.decode
    (resp |> Jooce.Protobuf.Response.decode).return_value |> Jooce.Protobuf.Services.decode
  end

  def puts_services(%Jooce.Protobuf.Services{services: services}, device \\ :stderr) do
    for service <- services do
      IO.puts device, service.name
      # string documentation = 5;
      # repeated Class classes = 3;
      # repeated Enumeration enumerations = 4;
      IO.puts device, "  Procedures:"
      puts_procedures service.procedures, device

      IO.puts device, ""
    end
  end

  def puts_procedures(procedures, device) do
    # %Jooce.Protobuf.Procedure{
    #   attributes: ["Class.Property.Set(Drawing.Text,Material)", "ParameterType(0).Class(Drawing.Text)"],
    #   documentation: "<doc>\n<summary>\nMaterial used to render the object.\nCreates the material from a shader with the given name.\n</summary>\n</doc>",
    #   has_return_type: false,
    #   parameters: [
    #     %Jooce.Protobuf.Parameter{default_value: "", has_default_value: false, name: "this", type: "uint64"},
    #     %Jooce.Protobuf.Parameter{default_value: "", has_default_value: false, name: "value", type: "string"}
    #   ],
    #   return_type: ""
    # }

    for procedure <- procedures do
      IO.puts device, "    #{procedure.name}"
    end
  end

# AddStream
# RemoveStream
# get_Clients
# get_CurrentGameScene

end
