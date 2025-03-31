defmodule MindsterGames.Games.GameGenServerTest do
  use MindsterGamesWeb.DataCase
  alias MindsterGames.Games.GameGenServer

  describe "join_game/2 - " do
    setup do
      game_id = "AB12"
      {:ok, game_pid} = GameGenServer.start_link(game_id)
      {:ok, %{game_pid: game_pid}}
    end

    test "player can join game", %{game_pid: game_pid} do
      player = "rolf"
      GameGenServer.join_game(game_pid, player)
      state = GameGenServer.info(game_pid)
      assert state.players == [player]
    end

    test "player can only join game once", %{game_pid: game_pid} do
      player = "rolf"
      GameGenServer.join_game(game_pid, player)
      GameGenServer.join_game(game_pid, player)
      state = GameGenServer.info(game_pid)
      assert state.players == [player]
    end
  end
end
