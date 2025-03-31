defmodule MindsterGamesWeb.LiveViewWebHelpers do
  @moduledoc """
  Adds `ok/1` and `noreply/1` for better ergonomy when writing liveview.

  ## Examples

  ```
  def mount(params, session, socket) do
    socket |> ok()
  end
  ```

  ```
  def mount(params, session, socket) do
    socket |> noreply()
  end
  ```
  """

  @spec ok(socket :: Phoenix.LiveView.Socket.t(), opts :: Keyword.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
          | {:ok, Phoenix.LiveView.Socket.t(), Keyword.t()}
  def ok(socket, opts \\ []) when is_list(opts) do
    if opts == [] do
      {:ok, socket}
    else
      {:ok, socket, opts}
    end
  end

  @spec noreply(socket :: Phoenix.LiveView.Socket.t(), opts :: Keyword.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
          | {:noreply, Phoenix.LiveView.Socket.t(), Keyword.t()}
  def noreply(socket, opts \\ []) when is_list(opts) do
    if opts == [] do
      {:noreply, socket}
    else
      {:noreply, socket, opts}
    end
  end
end
