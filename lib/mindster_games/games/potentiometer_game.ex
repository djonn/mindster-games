defmodule MindsterGames.Games.PotentiometerGame do
  use MindsterGames.Games.StateMachine

  defstruct players: [],
            teams: [],
            round: 0,
            current_team: nil,
            current_hinter: nil,
            current_goal: nil,
            current_scale: nil,
            current_guess: nil

  defmachine do
    state :awaiting_players
    state :starting_game
    state :hinter_picking
    state :guesser_picking
    state :reveal_result
    state :game_finished

    event :player_joined, from: :awaiting_players, to: :starting_game, if: player_count_valid?/2
    event :hinter_ready, from: :starting_game, to: :hinter_picking
    event :guesser_submits, from: :hinter_picking, to: :guesser_picking
    event :guesser_submits, from: :guesser_picking, to: :reveal_result
  end



  @impl MindsterGames.Games.StateMachine
  def mutate(state, :player_joined, data) do
    %{state | players: state.players ++ [data.player]}
  end

  @impl MindsterGames.Games.StateMachine
  def mutate(state, :guesser_submits, data) do
    %{state | current_guess: data.guess}
  end



  @impl MindsterGames.Games.StateMachine
  def enter(state, :starting_game) do
    %{
      state
      | round: 1,
      teams: [
        %{points: 0, players: [state.players[0], state.players[1]]},
        %{points: 0, players: [state.players[2], state.players[3]]}
      ],
      current_hinter: state.players[0],
    }
  end

  @impl MindsterGames.Games.StateMachine
  def enter(state, :hinter_picking) do
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

    %{state | current_goal: random_goal, current_scale: random_scale}
  end

  @impl MindsterGames.Games.StateMachine
  def enter(state, :reveal_result) do
    points = case abs(state.current_goal - state.current_guess) do
      diff when diff <= 10 -> 4
      diff when diff <= 20 -> 3
      diff when diff <= 30 -> 2
      diff when diff <= 40 -> 1
      _ -> 0
    end

    %{state | current_team: state.current_team + points}
  end



  defp player_count_valid?(state) do
    length(state.players) == 4
  end

end
