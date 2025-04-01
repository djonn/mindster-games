defmodule MindsterGamesWeb.Live.Room.InputComponents.NumberRangeComponent do
  use MindsterGamesWeb, :live_component

  alias MindsterGames.Games.GameGenServer

  def render(assigns) do
    # Use in future
    # https://codepen.io/josetxu/pen/oNQxxyZ
    ~H"""
    <div>
      <.form
        id="number-range-form"
        for={%{}}
        class="flex flex-col items-center"
        phx-target={@myself}
        phx-submit="submit"
      >
        <label for="value">
          <input type="range" id="value" name="value" min="0" max="100" value="50" />
        </label>
        <button class="text-slate-800 hover:text-slate-900">
          Submit
        </button>
      </.form>
    </div>
    """
  end

  def handle_event("submit", %{"value" => value}, socket) do
    GameGenServer.trigger(socket.assigns.game_pid, :number_range, value) |> dbg()
    socket |> noreply()
  end
end
