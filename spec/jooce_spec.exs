defmodule JooceSpec do
  use ESpec

  context "with a connection to KSP", requires_server: true do
    # start(name \\ "Jooce")
    # start_link(name \\ "Jooce")
    # stop(conn)
    # get_status
    # get_status(conn)
    # get_services
    # get_services(conn)
    # get_clients(conn)
    # get_current_scene(conn)
  end

  # puts_services(%Jooce.Protobuf.Services{services: services}, device \\ :stderr)
  # puts_enumerations(enumerations, device)
  # puts_procedures(procedures, device)

  # extract_client_info(item)
  # <<10, 17, 16, 106, 59, 235, 16, 90, 63, 219, 66, 184, 51, 7, 242, 19, 229, 170, 191, 10, 6, 5, 74, 111, 111, 99, 101, 10, 10, 9, 49, 50, 55, 46, 48, 46, 48, 46, 49>>
  # [{<<106, 59, 235, 16, 90, 63, 219, 66, 184, 51, 7, 242, 19, 229, 170, 191>>, "Jooce", "127.0.0.1"}]
end
