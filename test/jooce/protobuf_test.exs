defmodule JooceProtobufTest do
  use ExUnit.Case
  doctest Jooce.Protobuf

  test "encoding and decoding a message" do
    msg = Jooce.Protobuf.Request.new(service: "KRPC", procedure: "GetStatus")
    encoded = Jooce.Protobuf.Request.encode(msg)
    assert encoded == <<10, 4, 75, 82, 80, 67, 18, 9, 71, 101, 116, 83, 116, 97, 116, 117, 115>>
    decoded = Jooce.Protobuf.Request.decode(encoded)
    assert decoded == msg
  end

  test "encoding and decoding a varint" do
    encoded = :gpb.encode_varint(300)
    assert encoded == <<172, 2>>
    {decoded, _} = :gpb.decode_varint(encoded)
    assert decoded == 300
  end
end
