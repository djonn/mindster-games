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
            winning_team: nil,
            state: :awaiting_players

  defmachine field: :state do
    state(:awaiting_players)
    state(:hinter_picking, after_enter: &__MODULE__.setup_hinter_picking/2)
    state(:guesser_picking)
    state(:reveal_result, after_enter: &__MODULE__.calculate_points/2)
    state(:game_finished, after_enter: &__MODULE__.determine_winner/2)

    event :player_joined, before: &__MODULE__.add_player/2 do
      transition(
        from: :awaiting_players,
        to: :hinter_picking,
        if: &__MODULE__.player_count_valid?/2,
        after: &__MODULE__.initialize_teams/2
      )

      transition(from: :awaiting_players, to: :awaiting_players)
    end

    event :hinter_ready do
      transition(from: :hinter_picking, to: :guesser_picking)
    end

    event :guesser_submits, before: &__MODULE__.record_guess/2 do
      transition(from: :guesser_picking, to: :reveal_result)
    end

    event :next_round, after: &__MODULE__.rotate_team_and_hinter/2 do
      transition(from: :reveal_result, to: :hinter_picking, if: &__MODULE__.no_team_has_won?/2)
      transition(from: :reveal_result, to: :game_finished, unless: &__MODULE__.no_team_has_won?/2)
    end

    event :game_end do
      transition(from: :game_finished, to: :awaiting_players)
    end
  end

  # Event callbacks to handle payloads
  def add_player(model, %{payload: payload}) do
    player = payload.player
    updated_model = %__MODULE__{model | players: model.players ++ [player]}
    {:ok, updated_model}
  end

  def record_guess(model, %{payload: payload}) when is_integer(payload.guess) do
    guess = payload.guess
    updated_model = %__MODULE__{model | current_guess: guess}
    {:ok, updated_model}
  end

  def record_guess(_model, _ctx) do
    {:error, "Guess must be an integer"}
  end

  def rotate_team_and_hinter(model, _ctx) do
    next_round = model.round + 1
    {next_team_index, next_hinter} = get_current_team_and_hinter(%__MODULE__{model | round: next_round})

    updated_model = %__MODULE__{
      model
      | round: next_round,
        current_team: next_team_index,
        current_hinter: next_hinter
    }

    {:ok, updated_model}
  end

  # State callbacks
  def initialize_teams(model, _ctx) do
    {team1, team2} =
      model.players
      |> Enum.shuffle()
      |> Enum.split(2)

    updated_model = %__MODULE__{
      model
      | round: 1,
        teams: [
          %{points: 0, players: team1},
          %{points: 0, players: team2}
        ],
        current_team: 0,
        current_hinter: hd(team1)
    }

    {:ok, updated_model}
  end

  def setup_hinter_picking(model, _ctx) do
    random_goal = Enum.random(1..100)

    # full list in their translation sheet
    # https://docs.google.com/spreadsheets/d/1F4Afm5jF71LiLWyE1I98mFlwGbWOrabLDLaG6WJf_ak/edit?gid=1038837635#gid=1038837635
    random_scale =
      [
        {"Good habit", "Bad habit"},
        {"Dog person", "Cat person"},
        {"Expensive", "Cheap"},
        {"Daytime activity", "Nighttime activity"},
        {"Meal", "Snack"}
      ]
      |> Enum.random()

    updated_model = %__MODULE__{
      model
      | current_goal: random_goal,
        current_scale: random_scale
    }

    {:ok, updated_model}
  end

  def calculate_points(model, _ctx) do
    points =
      case abs(model.current_goal - model.current_guess) do
        diff when diff <= 10 -> 4
        diff when diff <= 20 -> 3
        diff when diff <= 30 -> 2
        diff when diff <= 40 -> 1
        _ -> 0
      end

    # Update the current team's points
    updated_teams =
      List.update_at(model.teams, model.current_team, fn team ->
        %{team | points: team.points + points}
      end)

    updated_model = %__MODULE__{model | teams: updated_teams}
    {:ok, updated_model}
  end

  def determine_winner(model, _ctx) do
    # Find the team with the highest points
    winner_index =
      Enum.find_index(model.teams, fn team ->
        team.points >= 5
      end)

    updated_model = %__MODULE__{model | winning_team: winner_index}
    {:ok, updated_model}
  end

  # Guards
  def player_count_valid?(model, _ctx) do
    length(model.players) + 1 == 4
  end

  def no_team_has_won?(model, _ctx) do
    not Enum.any?(model.teams, fn team -> team.points >= 5 end)
  end

  # Helper functions
  defp get_current_team_and_hinter(state) do
    team_count = Enum.count(state.teams)
    team_index = rem(state.round, team_count)

    players_on_team = state.teams |> Enum.at(team_index) |> Map.get(:players)
    players_on_team_count = Enum.count(players_on_team)

    hinter_index = state.round |> div(team_count) |> rem(players_on_team_count)
    hinter = players_on_team |> Enum.at(hinter_index)

    {team_index, hinter}
  end
end
