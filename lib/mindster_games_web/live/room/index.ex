defmodule MindsterGamesWeb.Live.Room.Index do
  alias MindsterGames.Games.GameGenServer
  use MindsterGamesWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    This is a room for {@room_id}
    """
  end

  @impl true
  def mount(%{"room_id" => room_id} = _params, _session, socket) do
    game_pid = MindsterGames.Application.game_pid()

    socket
    |> maybe_join_game(game_pid)
    |> assign(room_id: room_id)
    |> ok()
  end

  def maybe_join_game(socket, game_pid) do
    if connected?(socket) do
      case GameGenServer.join_game(game_pid, socket.assigns.player_id) do
        {:ok, _} -> socket
        {:error, _} -> socket |> push_navigate(to: ~p"/")
      end
    else
      socket
    end
  end
end
