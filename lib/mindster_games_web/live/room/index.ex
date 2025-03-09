defmodule MindsterGamesWeb.Live.Room.Index do
  use MindsterGamesWeb, :live_view

  def render(assigns) do
    ~H"""
    This is a room for {@room_id}
    """
  end

  def mount(%{"room_id" => room_id} = params, _session, socket) do
    dbg()
    {:ok, socket |> assign(room_id: room_id, page_title: "Room: #{room_id}")}
  end
end
