defmodule RFID.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {RFID.Monitor, [%{handler: RFID.Handler}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RFID.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
