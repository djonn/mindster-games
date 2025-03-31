defmodule MindsterGamesWeb.Live.IndexTest do
  alias MindsterGames.Games.GameGenServer
  use MindsterGamesWeb.ConnCase, async: true

  setup conn do
    on_exit(:close_gameserver, fn ->
      pid = MindsterGames.Application.game_pid()
      GenServer.stop(pid)
    end)

    conn
  end

  test "can join game room", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> fill_in("#game-id", "", with: "AB12", exact: false)
    |> submit()
    |> assert_path(~p"/AB12")

    # assert player joined game
    game_pid = MindsterGames.Application.game_pid()
    state = GameGenServer.info(game_pid)

    assert length(state.players) == 1
  end

  test "can't join game if game is full", %{conn: conn} do
    game_pid = MindsterGames.Application.game_pid()
    GameGenServer.join_game(game_pid, "player1")
    GameGenServer.join_game(game_pid, "player2")
    GameGenServer.join_game(game_pid, "player3")
    GameGenServer.join_game(game_pid, "player4")

    state = GameGenServer.info(game_pid)

    assert ["player1", "player2", "player3", "player4"] = state.players

    conn
    |> visit(~p"/")
    |> fill_in("#game-id", "", with: "AB12", exact: false)
    |> submit()
    |> refute_path(~p"/AB12")
    |> assert_path(~p"/")

    # assert player joined game
    state = GameGenServer.info(game_pid)

    assert ["player1", "player2", "player3", "player4"] = state.players
  end
end
