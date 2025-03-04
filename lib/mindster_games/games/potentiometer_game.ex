defmodule MindsterGames.Games.PotentiometerGame do
  use StateMachine

  defstruct players: [],
            teams: [],
            round: 0,
            current_team: nil,
            current_hinter: nil,
            current_goal: nil,
            current_scale: nil,
            current_guess: nil,
            state: :awaiting_players

  defmachine field: :state do
    state :awaiting_players
    state :starting_game, after_enter: &MindsterGames.Games.PotentiometerGame.setup_game/1
    state :hinter_picking, after_enter: &MindsterGames.Games.PotentiometerGame.setup_hinter_picking/1
    state :guesser_picking
    state :reveal_result, after_enter: &MindsterGames.Games.PotentiometerGame.calculate_points/1
    state :game_finished

    event :player_joined do
      transition from: :awaiting_players, to: :starting_game,
      if: &MindsterGames.Games.PotentiometerGame.player_count_valid?/1
    end

    event :hinter_ready do
      transition from: :starting_game, to: :hinter_picking
    end

    event :guesser_submits do
      transition from: :hinter_picking, to: :guesser_picking
      transition from: :guesser_picking, to: :reveal_result
    end
  end

  def mutate(state, :player_joined, data) do
    %{state | players: state.players ++ [data.player]}
  end

  def mutate(state, :guesser_submits, data) do
    %{state | current_guess: data.guess}
  end

  def setup_game(state) do
    updated_state = %{
      state
      | round: 1,
        teams: [
          %{points: 0, players: [state.players[0], state.players[1]]},
          %{points: 0, players: [state.players[2], state.players[3]]}
        ],
        current_hinter: state.players[0]
    }
    {:ok, updated_state}
  end

  def setup_hinter_picking(state) do
    random_goal = Enum.random(1..100)

    # full list in their translation sheet
    # https://docs.google.com/spreadsheets/d/1F4Afm5jF71LiLWyE1I98mFlwGbWOrabLDLaG6WJf_ak/edit?gid=1038837635#gid=1038837635
    random_scale = [
      {"Good habit", "Bad habit"},
      {"Dog person", "Cat person"},
      {"Expensive", "Cheap"},
      {"Daytime activity", "Nighttime activity"},
      {"Meal", "Snack"}
    ] |> Enum.random()

    updated_state = %{state | current_goal: random_goal, current_scale: random_scale}
    {:ok, updated_state}
  end

  def calculate_points(state) do
    points = case abs(state.current_goal - state.current_guess) do
      diff when diff <= 10 -> 4
      diff when diff <= 20 -> 3
      diff when diff <= 30 -> 2
      diff when diff <= 40 -> 1
      _ -> 0
    end

    updated_state = %{state | current_team: state.current_team + points}
    {:ok, updated_state}
  end

  def player_count_valid?(state) do
    length(state.players) == 4
  end
end
