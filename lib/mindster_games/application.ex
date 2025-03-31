defmodule MindsterGames.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MindsterGamesWeb.Telemetry,
      {Phoenix.PubSub, name: MindsterGames.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MindsterGames.Finch},
      # Start a worker by calling: MindsterGames.Worker.start_link(arg)
      # {MindsterGames.Worker, arg},
      # Start to serve requests, typically the last entry
      MindsterGamesWeb.Endpoint,
      MindsterGames.Games.GameGenServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MindsterGames.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MindsterGamesWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Hardcoded for now untill we can spawn GameRooms with a dynamic supervisor
  def game_pid() do
    Supervisor.which_children(MindsterGames.Supervisor)
    |> Enum.find(fn child -> elem(child, 0) == MindsterGames.Games.GameGenServer end)
    |> elem(1)
  end
end
