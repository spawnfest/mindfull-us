defmodule MindfullWeb.PageLiveTest do
  use MindfullWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "MindfullNest"
    assert render(page_live) =~ "MindfullNest"
  end
end
