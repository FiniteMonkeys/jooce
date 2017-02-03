defmodule Jooce do
  @moduledoc """
  Documentation for Jooce.
  """

  @doc ~S"""
  Open a connection to a kRPC server.
  """
  def start(name \\ "Jooce") do
    Jooce.Connection.start(name)
  end

  @doc ~S"""
  Open a connection to a kRPC server and links it to the current process.
  """
  def start_link(name \\ "Jooce") do
    Jooce.Connection.start_link(name)
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
      # service.documentation
      # repeated Class classes = 3;
      IO.puts device, "  Enumerations:"
      puts_enumerations service.enumerations, device
      IO.puts device, "  Procedures:"
      puts_procedures service.procedures, device

      IO.puts device, ""
    end
  end

  def puts_enumerations(enumerations, device) do
    for enum <- enumerations do
      IO.puts device, "    #{enum.name}"
      # enum.documentation
      for val <- enum.values do
        IO.puts device, "      #{val.value} = #{val.name}"
        # val.documentation
      end
    end
  end

  def puts_procedures(procedures, device) do
    for procedure <- procedures do
      param_strs = Enum.map(procedure.parameters, fn(x) -> "#{x.type} #{x.name}" end)   # would be nice to have x.default_value in there
      IO.write device, "    #{procedure.name}(#{Enum.join(param_strs, ", ")})"
      if procedure.has_return_type do
        IO.write device, " : #{procedure.return_type}"
      end
      IO.puts device, ""
      # procedure.documentation
      # procedure.attributes
    end
  end

  # AddStream(KRPC.Request request) : uint32
  # RemoveStream(uint32 id)

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
