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

    GameGenServer.trigger(game_pid, :hinter_ready)

    state = GameGenServer.info(game_pid)
    assert state.state == :guesser_picking
    assert is_number(state.current_goal)
    assert {left, right} = state.current_scale
    assert is_binary(left)
    assert is_binary(right)
  end
end
