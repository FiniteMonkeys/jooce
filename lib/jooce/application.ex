defmodule Jooce.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Jooce.ConnectionSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: Jooce.Application]

    Supervisor.start_link(children, opts)
  end
end
