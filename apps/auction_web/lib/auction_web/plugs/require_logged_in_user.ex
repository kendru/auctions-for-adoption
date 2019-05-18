defmodule AuctionWeb.Plugs.RequireLoggedInUser do
  import Plug.Conn
  use AuctionWeb, :controller

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    conn
    |> put_flash(:error, "You must be logged in to access that.")
    |> redirect(to: Routes.item_path(conn, :index))
    |> halt()
  end
  def call(conn, _opts), do: conn
end