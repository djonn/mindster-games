defmodule MindsterGamesWeb.Live.IndexTest do
  use MindsterGamesWeb.ConnCase

  test "can join game", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> fill_in("#game-id", "", with: "AB12", exact: false)
    |> submit()
    |> assert_path(~p"/AB12")
  end
end
