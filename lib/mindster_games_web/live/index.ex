defmodule MindsterGamesWeb.Live.Index do
  use MindsterGamesWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-12 w-full justify-center pb-24">
      <div class="w-full items-center flex flex-col content-center gap-1.5">
        <h2 class="text-5xl">Welcome to</h2>
        <h1 class="text-6xl font-semibold">
          Mindster Games
        </h1>
      </div>
      <.button class="bg-brand font-normal cursor-pointer text-2xl hover:bg-brand/10 font-medium">
        Join Game
      </.button>
    </div>
    """
  end
end
