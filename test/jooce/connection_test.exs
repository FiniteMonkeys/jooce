defmodule JooceConnectionTest do
  use ExUnit.Case
  doctest Jooce.Connection

  test "procedural Erlang" do
    # assert 1 + 1 == 2
    IO.puts("connecting")
    {:ok, sock} = :gen_tcp.connect('localhost', 50000, [:binary, {:active, false}, {:packet, :raw}], 5000)
    IO.puts("sending hello")
    :ok = :gen_tcp.send(sock, <<0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x2D, 0x52, 0x50, 0x43, 0x00, 0x00, 0x00>>)
    IO.puts("sending name")
    <<packet::binary-size(32), _::binary>> = "Jooce" <> String.duplicate(<<0>>, 32)
    :ok = :gen_tcp.send(sock, packet)
    IO.puts("receiving GUID")
    {:ok, guid} = :gen_tcp.recv(sock, 16, 10000)
    IO.puts(inspect guid)
    IO.puts("closing connection")
    :ok = :gen_tcp.close(sock)
  end

  test "procedural Elixir" do
    IO.puts("connecting")
    {:ok, conn} = Jooce.Connection.start_link
    IO.puts("getting guid")
    {:ok, guid} = Jooce.Connection.guid(conn)
    IO.puts(inspect guid)
    IO.puts("closing connection")
    :ok = Jooce.Connection.close(conn)
  end
end
