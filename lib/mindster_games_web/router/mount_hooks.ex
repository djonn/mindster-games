defmodule MindsterGamesWeb.Router.MountHooks do
  def on_mount(:default, _params, _session, socket) do
    # TODO: communicate with GenServer about going to room

    {:cont, socket}
  end
end
