{:ok, conn} = Jooce.start_link
Jooce.get_services(conn) |> Jooce.describe_services
Jooce.stop(conn)
