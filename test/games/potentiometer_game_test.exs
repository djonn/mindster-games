defmodule MindsterGames.Games.PotentiometerGameTest do
  use MindsterGamesWeb.DataCase

  alias MindsterGames.Games.{GameGenServer, PotentiometerGame}

  test "When new game starts then game is awaiting players" do
    {:ok, game_pid} = GameGenServer.start_link()

    state = GameGenServer.info(game_pid)
    assert state.players == []
    assert state.state == :awaiting_players
  end

  test "When fewer than 4 players join then game is still awaiting players" do
    {:ok, game_pid} = GameGenServer.start_link()

    player1 = "player1"
    player2 = "player2"

    GameGenServer.trigger(game_pid, :player_joined, %{player: player1})
    GameGenServer.trigger(game_pid, :player_joined, %{player: player2})

    state = GameGenServer.info(game_pid)
    assert state.players == [player1, player2]
    assert state.state == :awaiting_players
  end

  test "When player number 4 joins then the game starts" do
    {:ok, game_pid} = GameGenServer.start_link()

    player1 = "player1"
    player2 = "player2"
    player3 = "player3"
    player4 = "player4"

    GameGenServer.trigger(game_pid, :player_joined, %{player: player1})
    GameGenServer.trigger(game_pid, :player_joined, %{player: player2})
    GameGenServer.trigger(game_pid, :player_joined, %{player: player3})
    GameGenServer.trigger(game_pid, :player_joined, %{player: player4})

    state = GameGenServer.info(game_pid)
    assert state.players == [player1, player2, player3, player4]
    assert state.state == :hinter_picking
  end

  test "When starting game and hint has been given, then guesser can start" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      teams: [%{points: 0, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
      round: 1,
      current_team: 0,
      current_hinter: "player1",
      current_goal: 50,
      current_scale: {"good", "bad"},
      state: :hinter_picking
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :hinter_ready)

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :guesser_picking
    assert is_number(state.current_goal)
    assert {left, right} = state.current_scale
    assert is_binary(left)
    assert is_binary(right)
  end

  test "When hinter is chosen then hinter can provide a clue" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      teams: [%{points: 0, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
      round: 1,
      current_team: 0,
      current_hinter: "player1",
      current_goal: 50,
      current_scale: {"good", "bad"},
      state: :hinter_picking
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :hinter_ready)

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :guesser_picking
  end

  describe "Scoring - " do
    setup do
      existing_state = %PotentiometerGame{
        players: ["player1", "player2", "player3", "player4"],
        state: :guesser_picking,
        teams: [%{points: 0, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
        current_team: 0,
        current_goal: 50,
        current_guess: nil
      }

      {:ok, game_pid} = GameGenServer.start_link(existing_state)

      {:ok, game_pid: game_pid}
    end

    test "When guess is within 10 of goal then team scores 4 points", %{game_pid: game_pid} do
      response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 55})

      assert not is_error?(response)

      state = GameGenServer.info(game_pid)
      assert state.state == :reveal_result
      assert hd(state.teams).points == 4
    end

    test "When guess is within 20 of goal then team scores 3 points", %{game_pid: game_pid} do
      response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 65})

      assert not is_error?(response)

      state = GameGenServer.info(game_pid)
      assert state.state == :reveal_result
      assert hd(state.teams).points == 3
    end

    test "When guess is within 30 of goal then team scores 2 points", %{game_pid: game_pid} do
      response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 75})

      assert not is_error?(response)

      state = GameGenServer.info(game_pid)
      assert state.state == :reveal_result
      assert hd(state.teams).points == 2
    end

    test "When guess is within 40 of goal then team scores 1 point", %{game_pid: game_pid} do
      response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 85})

      assert not is_error?(response)

      state = GameGenServer.info(game_pid)
      assert state.state == :reveal_result
      assert hd(state.teams).points == 1
    end

    test "When guess is more than 40 away from goal then team scores 0 points", %{game_pid: game_pid} do
      response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 95})

      assert not is_error?(response)

      state = GameGenServer.info(game_pid)
      assert state.state == :reveal_result
      assert hd(state.teams).points == 0
    end
  end

  test "When guesser submits a guess then result is revealed" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      teams: [%{points: 0, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
      round: 1,
      current_team: 0,
      current_hinter: "player1",
      current_goal: 50,
      current_scale: {"good", "bad"},
      state: :guesser_picking
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: 75})

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :reveal_result
  end

  test "When no team has won then game continues to next round and new scale and goal are picked" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      # scores are below winning threshold
      teams: [%{points: 3, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
      round: 1,
      current_team: 0,
      current_hinter: "player1",
      current_goal: 50,
      current_scale: {"good", "bad"},
      state: :reveal_result
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :next_round)

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :hinter_picking

    assert is_number(state.current_goal)
    assert state.current_goal != 50

    assert {left, right} = state.current_scale
    assert is_binary(left)
    assert is_binary(right)
    assert left != "good"
    assert right != "bad"
  end

  test "When a team reaches the winning score then game ends" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      # scores are above winning threshold
      teams: [%{points: 3, players: ["player1", "player2"]}, %{points: 7, players: ["player3", "player4"]}],
      round: 1,
      current_team: 0,
      current_hinter: "player1",
      current_goal: 50,
      current_scale: {"good", "bad"},
      state: :reveal_result
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :next_round)

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :game_finished
    assert state.winning_team == 1
  end

  test "When team has won and game ends then game resets to awaiting players on restart" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      state: :game_finished
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :game_end)

    assert not is_error?(response)

    # default values but with players from previous game
    expected_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      state: :awaiting_players
    }

    state = GameGenServer.info(game_pid)
    assert expected_state == state
  end

  test "Given an ongoing game when a player tries to join then player is not added" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      state: :hinter_picking
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :player_joined, %{player: "player5"})

    assert is_error?(response)

    state = GameGenServer.info(game_pid)
    assert "player5" not in state.players
    assert state.state == :hinter_picking
  end

  test "When next round starts then teams and roles rotate" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      teams: [%{points: 0, players: ["player1", "player2"]}, %{points: 0, players: ["player3", "player4"]}],
      state: :reveal_result,
      round: 0,
      current_team: 0,
      current_hinter: "player1"
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :next_round)

    assert not is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.round == 1

    assert state.current_team != 0
    assert state.current_hinter != "player1"

    assert state.current_team == 1
    assert state.current_hinter == "player3"

  end

  test "When an invalid guess is submitted then state does not change" do
    existing_state = %PotentiometerGame{
      players: ["player1", "player2", "player3", "player4"],
      state: :guesser_picking
    }

    {:ok, game_pid} = GameGenServer.start_link(existing_state)

    response = GameGenServer.trigger(game_pid, :guesser_submits, %{guess: "invalid"})

    assert is_error?(response)

    state = GameGenServer.info(game_pid)
    assert state.state == :guesser_picking
  end

  defp is_error?(response) do
    case response do
      {:error, _} -> true
      _ -> false
    end
  end

end
