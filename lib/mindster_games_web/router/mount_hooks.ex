defmodule MindsterGamesWeb.Router.MountHooks do
  def on_mount(:default, _params, session, socket) do
    # TODO: communicate with GenServer about going to room
    player_id = Map.get(session, "_csrf_token")
    {:cont, socket |> Phoenix.Component.assign(player_id: player_id)}
  end
end
