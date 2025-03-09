defmodule MindsterGamesWeb.Live.Index do
  use MindsterGamesWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <div class="w-full items-center flex flex-col content-center gap-1.5 text-slate-900">
        <h2 class="text-5xl">Welcome to</h2>
        <h1 class="text-6xl font-semibold">
          Mindster Games
        </h1>
      </div>
      <.form for={%{}} class="flex flex-col items-center" phx-change="validate">
        <input
          id="game_id"
          name="game_id"
          class="rounded-lg py-2 px-3 bg-brand font-normal cursor-pointer text-2xl hover:bg-brand/10 font-medium text-red-100 w-full placeholder:text-white/80 text-white/80 text-center"
          placeholder="Enter Game Code"
        />
        <button class={["text-slate-800 hover:text-slate-900", not @any_text? and "opacity-0"]}>
          press enter to join
        </button>
      </.form>
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

  def mount(params, session, socket) do
    dbg()
    {:ok, socket |> assign(any_text?: false)}
  end

  def handle_event("validate", params, socket) do
    {:noreply, socket |> assign(any_text?: params["game_id"] != "")}
  end
end
