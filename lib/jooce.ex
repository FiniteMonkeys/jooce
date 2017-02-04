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
  Open a connection to a kRPC server and link it to the current process.
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
  Returns some information about the server, such as the version.

  ## RPC signature
  GetStatus() : KRPC.Status
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
  Returns information on all services, procedures, classes, properties etc. provided by the server.
  Can be used by client libraries to automatically create functionality such as stubs.

  ## RPC signature
  GetServices() : KRPC.Services
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

  def describe_services(%Jooce.Protobuf.Services{services: services}, device \\ :stderr) do
    for service <- services, do: describe_service(service, device)
  end

  @doc ~S"""
  Add a streaming request and return its identifier.

  ## RPC signature
  AddStream(KRPC.Request request) : uint32
  """
  def add_stream do

  end

  @doc ~S"""
  Remove a streaming request.

  ## RPC signature
  RemoveStream(uint32 id)
  """
  def remove_stream do

  end

  @doc ~S"""
  A list of RPC clients that are currently connected to the server.
  Each entry in the list is a clients identifier, name and address.

  ## RPC signature
  get_Clients() : KRPC.List
  """
  def get_clients(conn) do
    {:ok, return_value, _} = Jooce.Connection.call_rpc(conn, "KRPC", "get_Clients")
    Enum.map(Jooce.Protobuf.List.decode(return_value).items, fn(x) -> extract_client_info(x) end)
  end

  @doc ~S"""
  Get the current game scene.

  ## RPC signature
  get_CurrentGameScene() : int32
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
    end
  end

  ##
  ## private functions
  ##

  defp extract_client_info(item) do
    IO.puts(inspect item)
    [raw_guid, raw_name, raw_ip_address] = (Jooce.Protobuf.Tuple.decode(item)).items
    <<_ :: size(8), guid :: binary>> = raw_guid
    <<_ :: size(8), name :: binary>> = raw_name
    <<_ :: size(8), ip_address :: binary>> = raw_ip_address
    {guid, name, ip_address}
  end

  def describe_service(%{name: "KRPC"} = service, device) do
    IO.puts device, "defmodule Jooce.#{service.name} do"
    # IO.puts device, (inspect service)
    describe_module_doc(service.documentation, device)
    # service.classes
    # service.enumerations
    # service.procedures
    describe_procedures(service.procedures, device)

    IO.puts device, "end"
  end

  def describe_service(_service, _device) do

  end

  def describe_module_doc(documentation, device) do
    IO.puts device, ~s(  @moduledoc ~S""")
    for line <- String.split(documentation, "\n", trim: true) do
      IO.puts device, "  #{line}"
    end
    IO.puts device, ~s(  """)
  end

  # def describe_enumerations(enumerations, device) do
  #   for enum <- enumerations do
  #     IO.puts device, "    #{enum.name}"
  #     # enum.documentation
  #     for val <- enum.values do
  #       IO.puts device, "      #{val.value} = #{val.name}"
  #       # val.documentation
  #     end
  #   end
  # end

  def describe_procedures(procedures, device) do
    for procedure <- procedures, do: describe_procedure(procedure, device)
  end

  def describe_procedure(procedure, device) do
    IO.puts device, ~s(\n  @doc ~S""")
    # IO.puts device, (inspect procedure)
    for line <- String.split(procedure.documentation, "\n", trim: true) do
      IO.puts device, "  #{line}"
    end
    IO.puts device, ~s(\n  ## RPC signature)
    IO.write device, "  #{procedure.name}(#{Enum.join(Enum.map(procedure.parameters, fn(x) -> "#{x.type} #{x.name}" end), ", ")})"
    if procedure.has_return_type do
      IO.write device, " : #{procedure.return_type}"
    end
    IO.puts device, ""
    # procedure.attributes
    # procedure.has_return_type
    # procedure.name
    # procedure.parameters
    # procedure.return_type
    IO.puts device, ~s(  """)
  end

end
