defmodule MindsterGames.Games.GameGenServer do
  use GenServer

  alias MindsterGames.Games.PotentiometerGame

  def start_link(initial_state \\ nil, opts \\ [])

  def start_link(initial_state, opts) when is_nil(initial_state) do
    initial_state = %PotentiometerGame{}
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def start_link(initial_state, opts) do
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  # ---- Client API -------
  def trigger(pid, event, payload \\ nil) do
    GenServer.call(pid, {:trigger, event, payload})
  end

  def info(pid) do
    GenServer.call(pid, :info)
  end

  # ---- Server Callbacks -------
  def handle_call({:trigger, event, payload}, _from, state) do
    {:ok, new_state} = PotentiometerGame.trigger(state, event, payload)
    {:reply, new_state, new_state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
end
