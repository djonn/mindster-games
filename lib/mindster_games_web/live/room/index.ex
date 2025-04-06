defmodule MindsterGamesWeb.Live.Room.Index do
  use MindsterGamesWeb, :live_view

  alias MindsterGames.Games.GameGenServer
  alias MindsterGamesWeb.Live.Room.InputComponents.{NumberRangeComponent, SelectComponent}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <.waiting_for_players :if={@request_type == :wait} data={@request_data} />

      <.live_component
        :if={@request_type == :number_range}
        id="number-range"
        module={NumberRangeComponent}
        game_pid={@game_pid}
        data={@request_data}
      />

      <.live_component
        :if={@request_type == :select}
        id="select"
        module={SelectComponent}
        game_pid={@game_pid}
        data={@request_data}
      />

      <.circles />
    </div>
    """
  end

  defp waiting_for_players(assigns) do
    assigns = assigns |> assign(:text, Map.get(assigns.data, :title, "Waiting for other players"))

    ~H"""
    <div class="w-full items-center flex flex-col content-center gap-1.5 text-slate-900">
      <h2 class="text-5xl">{@text}</h2>
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

    # This would come from a subscription to the game server in the future
    # request = {:wait, %{title: "Waiting for other players.."}}
    # request = {:select, %{title: "Pick a hint", options: [%{id: "ready", text: "Ready!"}]}}
    request = {:number_range, %{title: "Meal or Snack?", initial: 75}}

    socket
    |> maybe_join_game(game_pid)
    |> assign(game_pid: game_pid)
    |> assign(room_id: room_id)
    |> assign(page_title: "#{room_id}")
    |> assign_request(request)
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

  @spec assign_request(
          socket :: Phoenix.LiveView.Socket.t(),
          request :: MindsterGames.Games.Types.ServerToUser.request()
        ) :: Phoenix.LiveView.Socket.t()
  defp assign_request(socket, {type, data} = _request) when is_atom(type) and is_map(data) do
    socket
    |> assign(request_type: type)
    |> assign(request_data: data)
  end
end
