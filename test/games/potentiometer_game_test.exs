defmodule MindsterGames.Games.PotentiometerGameTest do
  use MindsterGamesWeb.DataCase
  alias MindsterGames.Games.GameGenServer

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

  test "4 players join and the game starts" do
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
    assert state.state == :starting_game
  end
end
