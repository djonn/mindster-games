defmodule MindsterGamesWeb.Live.Room.Index do
  alias MindsterGames.Games.GameGenServer
  use MindsterGamesWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <.waiting_for_players :if={@game_state == :waiting_for_players} />
      <.submit_number_potentiometer :if={@game_state == :submit_number_potentiometer} />
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

  defp submit_number_potentiometer(assigns) do
    # https://codepen.io/josetxu/pen/oNQxxyZ
    ~H"""
    <div class="w-full items-center flex flex-col content-center gap-1.5 text-slate-900">
      <h2 class="text-5xl">Submit Number Potentiometer</h2>
      <input type="range" />
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
    |> assign(room_id: room_id)
    |> assign(page_title: "#{room_id}")
    |> assign(game_state: :submit_number_potentiometer)
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
