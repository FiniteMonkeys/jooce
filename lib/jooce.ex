defmodule Jooce do
  @moduledoc """
  Documentation for Jooce.
  """

  @doc """
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
    {:ok, conn} = Jooce.Connection.start_link
    status = get_status(conn)
    Jooce.Connection.close(conn)
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

  @doc """
  Returns status information about the server.

  ## Reference

  https://krpc.github.io/krpc/communication-protocol.html#getservices

  ## Examples

      iex> Jooce.get_services

  """
  def get_services do
    req = Jooce.Protobuf.Request.new(service: "KRPC", procedure: "GetServices")
          |> Jooce.Protobuf.Request.encode
    req_len = String.length(req) |> :gpb.encode_varint

    {:ok, conn} = Jooce.Connection.start_link
    Jooce.Connection.send(conn, req_len <> req)

    {resp_len, _} = Jooce.Utils.read_varint(conn) |> :gpb.decode_varint
    {:ok, resp} = Jooce.Connection.recv(conn, resp_len)
    # IO.puts inspect (resp |> Jooce.Protobuf.Response.decode).return_value |> Jooce.Protobuf.Services.decode
    ((resp |> Jooce.Protobuf.Response.decode).return_value |> Jooce.Protobuf.Services.decode).services |> Jooce.puts_services

    Jooce.Connection.close(conn)
  end

  def puts_services([]), do: true
  def puts_services([ service ]), do: puts_service(service)
  def puts_services([ service | rest ]) do
    puts_service(service)
    puts_services(rest)
  end

  def puts_service(service) do
    IO.puts service.name
    # string documentation = 5;
    # repeated Class classes = 3;
    # repeated Enumeration enumerations = 4;
    IO.puts "  Procedures:"
    Jooce.puts_procedures(service.procedures)
    IO.puts ""
  end

  def puts_procedures([]), do: true
  def puts_procedures([ procedure ]), do: puts_procedure(procedure)
  def puts_procedures([ procedure | rest ]) do
    puts_procedure(procedure)
    puts_procedures(rest)
  end

  def puts_procedure(procedure) do
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

    IO.puts "    #{procedure.name}"
  end


# AddStream
# RemoveStream
# get_Clients
# get_CurrentGameScene


end
