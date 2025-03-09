defmodule MindsterGamesWeb.Live.Index do
  use MindsterGamesWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <div class="w-full items-center flex flex-col content-center gap-1.5 text-slate-900">
        <h2 class="text-5xl">Welcome to</h2>
        <h1 class="text-6xl font-semibold text-center">
          Mindster Games
        </h1>
      </div>
      <.join_input />
      <.create_game_button />
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
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("join-room", %{"game_id" => _game_id}, socket) do
    # TODO: Join Game Logic
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-room", _unsigned_params, socket) do
    # TODO: Create Game Logic
    {:noreply, socket}
  end

  defp join_input(assigns) do
    ~H"""
    <.form for={%{}} class="flex flex-col items-center" phx-submit="join-room">
      <input
        id="game_id"
        name="game_id"
        class={[
          "peer rounded-lg py-2 px-3 w-full cursor-pointer",
          "uppercase placeholder-shown:normal-case font-medium text-2xl placeholder:text-white/80 text-white/80 text-center",
          "bg-brand hover:bg-brand/10"
        ]}
        placeholder="Enter Game Code"
      />
      <button
        class="text-slate-800 hover:text-slate-900 peer-placeholder-shown:opacity-0"
        tabindex="-1"
      >
        - press enter to join -
      </button>
    </.form>
    """
  end

  defp create_game_button(assigns) do
    ~H"""
    <button
      class="px-3 py-2 bg-violet-400/80 rounded-lg hover:bg-violet-400/60 text-white font-medium"
      phx-click="create-room"
    >
      Create Room
    </button>
    """
  end
end
