defmodule Auction.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Auction.Repo, []}
    ]

    opts = [strategy: :one_for_one, name: Auction.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
