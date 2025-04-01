defmodule MindsterGamesWeb.Live.Room.Index do
  use MindsterGamesWeb, :live_view

  alias MindsterGames.Games.GameGenServer
  alias MindsterGamesWeb.Live.Room.InputComponents.NumberRangeComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <.waiting_for_players :if={@game_state == :waiting_for_players} />
      <.live_component
        :if={@game_state == :number_range}
        id="number-range"
        module={NumberRangeComponent}
        game_pid={@game_pid}
      />

      <.circles />
    </div>
    """
  end

  defp waiting_for_players(assigns) do
    ~H"""
    <div class="w-full items-center flex flex-col content-center gap-1.5 text-slate-900">
      <h2 class="text-5xl">Waiting for other players</h2>
    </div>
    """
  end

  defp circles(assigns) do
    ~H"""
    <ul class="circles -z-10">
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
      <li></li>
    </ul>
    """
  end

  @impl true
  def mount(%{"room_id" => room_id} = _params, _session, socket) do
    game_pid = MindsterGames.Application.game_pid()

    socket
    |> maybe_join_game(game_pid)
    |> assign(game_pid: game_pid)
    |> assign(room_id: room_id)
    |> assign(page_title: "#{room_id}")
    |> assign(game_state: :number_range)
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
