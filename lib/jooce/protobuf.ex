defmodule Jooce.Protobuf do
  use Protobuf, from: Path.wildcard(Path.expand("../proto/krpc.proto", __DIR__))
  @moduledoc false
end
