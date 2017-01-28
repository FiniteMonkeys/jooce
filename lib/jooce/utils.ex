defmodule Jooce.Utils do
  @moduledoc """
  Utilities for Jooce.
  """

  @doc """
  Reads a varint from the server.

  """
  def read_varint(conn, buffer \\ <<>>) do
    case Jooce.Connection.recv(conn, 1) do
      {:ok, <<1 :: size(1), _ :: bitstring>> = byte} ->
        read_varint(conn, buffer <> byte)
      {:ok, <<0 :: size(1), _ :: size(7)>> = byte} ->
        buffer <> byte
      _ ->
        buffer
    end
  end
end
