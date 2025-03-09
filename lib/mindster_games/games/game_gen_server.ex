defmodule MindsterGames.Games.GameGenServer do
  use GenServer

  alias MindsterGames.Games.PotentiometerGame

  def start_link(_initial_state, opts \\ []) do
    initial_state = %PotentiometerGame{}
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

  def join_game(pid, player) do
    GenServer.call(pid, {:join_game, player})
  end

  def get_current_state(pid) do
    GenServer.call(pid, :get_current_state)
  end

  # ---- Server Callbacks -------
  def handle_call({:trigger, event, payload}, _from, state) do
    {:ok, new_state} = PotentiometerGame.trigger(state, event, payload)
    {:reply, new_state, new_state}
  end

  def handle_call({:join_game, player}, _from, state) do
    if Enum.any?(state.players, fn current_player -> current_player == player end) do
      {:reply, {:ok, state}, state}
    else
      {:ok, new_state} = PotentiometerGame.trigger(state, :player_joined, %{player: player})
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call(:get_current_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
end
