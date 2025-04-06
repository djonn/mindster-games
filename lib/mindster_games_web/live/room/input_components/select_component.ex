defmodule MindsterGamesWeb.Live.Room.InputComponents.SelectComponent do
  use MindsterGamesWeb, :live_component

  alias MindsterGames.Games.GameGenServer

  attr :title, :string, default: "Pick one"
  attr :options, :list, required: true

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <p class="text-4xl font-semibold text-center pb-4">{@title}</p>
      <button
        :for={option <- @options}
        class="px-3 py-2 bg-violet-400/80 rounded-lg hover:bg-violet-400/60 text-white font-medium"
        phx-target={@myself}
        phx-click="submit"
        phx-value={option.id}
      >
        {option.text}
      </button>
    </div>
    """
  end

  def handle_event("submit", %{"value" => value}, socket) do
    GameGenServer.trigger(socket.assigns.game_pid, :select, value) |> dbg()
    socket |> noreply()
  end
end
