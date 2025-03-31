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
    socket
    |> assign(
      room_id: room_id,
      page_title: "Room: #{room_id}"
    )
    |> maybe_join_game_room()
    |> ok()
  end

  defp maybe_join_game_room(socket) do
    game_pid = MindsterGames.Application.game_pid()

    with {:ok, _state} <- GameGenServer.join_game(game_pid, socket.assigns.player_id) do
      socket
    else
      _ -> socket |> push_navigate(to: ~p"/")
    end
  end
end
