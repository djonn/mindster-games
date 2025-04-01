defmodule MindsterGames.Games.GameGenServer do
  use GenServer

  alias MindsterGames.Games.PotentiometerGame

  def start_link(initial_state \\ nil, opts \\ [])

  def start_link(initial_state, opts) when is_nil(initial_state) or initial_state == [] do
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

  @spec join_game(pid :: pid(), player_id :: term()) :: {:ok, map()} | {:error, term()}
  def join_game(pid, player_id) do
    GenServer.call(pid, {:join_game, player_id})
  end

  def info(pid) do
    GenServer.call(pid, :info)
  end

  # ---- Server Callbacks -------
  def handle_call({:trigger, event, payload}, _from, state) do
    case PotentiometerGame.trigger(state, event, payload) do
      {:ok, new_state} ->
        {:reply, new_state, new_state}

      {:error, _} = error ->
        # The error message here could be improved
        # when the state machine cannot apply an event it returns
        # `{:error, {:transition, "Couldn't resolve transition"}}`
        {:reply, error, state}
    end
  end

  def handle_call({:join_game, player_id}, _from, state) do
    if PotentiometerGame.already_joined?(state, player_id) do
      {:reply, {:ok, state}, state}
    else
      case PotentiometerGame.trigger(state, :player_joined, %{player: player_id}) do
        {:ok, new_state} ->
          {:reply, {:ok, new_state}, new_state}

        {:error, _} = error ->
          # The error message here could be improved
          # when the state machine cannot apply an event it returns
          # `{:error, {:transition, "Couldn't resolve transition"}}`
          {:reply, error, state}
      end
    end
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
end
