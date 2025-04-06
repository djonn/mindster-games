defmodule MindsterGamesWeb.Live.Room.InputComponents.NumberRangeComponent do
  use MindsterGamesWeb, :live_component

  alias MindsterGames.Games.GameGenServer

  @default_attributes %{
    title: "",
    min: 0,
    max: 100,
    initial: 50
  }

  attr :data, :map, required: true

  def render(assigns) do
    assigns =
      assigns
      |> assign(Map.merge(@default_attributes, assigns.data))

    # Use in future
    # https://codepen.io/josetxu/pen/oNQxxyZ
    ~H"""
    <div>
      <p class="text-4xl font-semibold text-center pb-4">{@title}</p>
      <.form
        id="number-range-form"
        for={%{}}
        class="flex flex-col items-center"
        phx-target={@myself}
        phx-submit="submit"
      >
        <label for="value">
          <input type="range" id="value" name="value" min={@min} max={@max} value={@initial} />
        </label>
        <button class="px-3 py-2 bg-violet-400/80 rounded-lg hover:bg-violet-400/60 text-white font-medium">
          Submit
        </button>
      </.form>
    </div>
    """
  end

  def handle_event("submit", %{"value" => value}, socket) do
    GameGenServer.trigger(socket.assigns.game_pid, :number_range, value)
    send(self(), :submitted)
    socket |> noreply()
  end
end
