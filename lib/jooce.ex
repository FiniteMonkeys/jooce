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
    {:ok, return_value, _} = Jooce.Connection.call_rpc(conn, "KRPC", "GetStatus")
    Jooce.Protobuf.Status.decode(return_value)
  end

  @doc ~S"""
  Returns a list of all services.

  ## Reference

  https://krpc.github.io/krpc/communication-protocol.html#getservices

  """
  def get_services do
    {:ok, conn} = Jooce.Connection.start
    services = get_services(conn)
    Jooce.Connection.stop(conn)
    services
  end

  def get_services(conn) do
    {:ok, return_value, _} = Jooce.Connection.call_rpc(conn, "KRPC", "GetServices")
    Jooce.Protobuf.Services.decode(return_value)
  end

  def puts_services(%Jooce.Protobuf.Services{services: services}, device \\ :stderr) do
    for service <- services do
      IO.puts device, service.name
      # string documentation = 5;
      # repeated Class classes = 3;
      # repeated Enumeration enumerations = 4;
      IO.puts device, "  Enumerations:"
      puts_enumerations service.enumerations, device
      IO.puts device, "  Procedures:"
      puts_procedures service.procedures, device

      IO.puts device, ""
    end
  end

  def puts_enumerations(enumerations, device) do
    # %Jooce.Protobuf.Enumeration{
    #   documentation: "<doc>\n<summary>\nFont style.\n</summary>\n</doc>",
    #   name: "FontStyle",
    #   values: [
    #     %Jooce.Protobuf.EnumerationValue{
    #       documentation: "<doc>\n<summary>\nNormal.\n</summary>\n</doc>",
    #       name: "Normal",
    #       value: 0
    #     },
    #     %Jooce.Protobuf.EnumerationValue{
    #       documentation: "<doc>\n<summary>\nBold.\n</summary>\n</doc>",
    #       name: "Bold",
    #       value: 1
    #     },
    #     %Jooce.Protobuf.EnumerationValue{
    #       documentation: "<doc>\n<summary>\nItalic.\n</summary>\n</doc>",
    #       name: "Italic",
    #       value: 2
    #     },
    #     %Jooce.Protobuf.EnumerationValue{
    #       documentation: "<doc>\n<summary>\nBold and italic.\n</summary>\n</doc>",
    #       name: "BoldAndItalic",
    #       value: 3
    #     }
    #   ]
    # }
    for enum <- enumerations do
      IO.puts device, "    #{enum.name}"
      for val <- enum.values do
        IO.puts device, "      #{val.value} = #{val.name}"
      end
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

  @doc ~S"""
  Returns a list of connected clients.

  Each item in the list is a tuple of
  * byte[] containing the client's guid
  * string containing the client's name
  * string containing the client's IP address
  """
  def get_clients(conn) do
    {:ok, return_value, _} = Jooce.Connection.call_rpc(conn, "KRPC", "get_Clients")
    Enum.map(Jooce.Protobuf.List.decode(return_value).items, fn(x) -> extract_client_info(x) end)
  end

  def extract_client_info(item) do
    [raw_guid, raw_name, raw_ip_address] = (Jooce.Protobuf.Tuple.decode(item)).items
    <<_ :: size(8), guid :: binary>> = raw_guid
    <<_ :: size(8), name :: binary>> = raw_name
    <<_ :: size(8), ip_address :: binary>> = raw_ip_address
    {guid, name, ip_address}
  end

  @doc ~S"""
  Returns the current game scene.

  """
  def get_current_scene(conn) do
    {:ok, return_value, _} = Jooce.Connection.call_rpc(conn, "KRPC", "get_CurrentGameScene")
    case return_value do
      <<0>> ->
        :space_center
      <<1>> ->
        :flight
      <<2>> ->
        :tracking_station
      <<3>> ->
        :vab
      <<4>> ->
        :sph
      _ ->
        :unknown
    end
  end

end
