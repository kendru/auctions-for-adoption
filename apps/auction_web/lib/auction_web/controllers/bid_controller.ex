defmodule AuctionWeb.BidController do
  use AuctionWeb, :controller
  plug AuctionWeb.Plugs.RequireLoggedInUser

  def create(conn, %{"bid" => %{"amount" => amount},
                     "item_id" => item_id}) do
    user_id = conn.assigns.current_user.id
    amount_in_cents = case Float.parse(amount) do
      {amount_in_dollars, _} -> trunc(amount_in_dollars * 100)
      _ -> 0
    end

    case Auction.insert_bid(%{amount: amount_in_cents, item_id: item_id, user_id: user_id}) do
      {:ok, bid} ->
        html = Phoenix.View.render_to_string(AuctionWeb.BidView,
                                             "bid.html",
                                             bid: bid,
                                             username: conn.assigns.current_user.username)
        AuctionWeb.Endpoint.broadcast("item:#{item_id}", "new_bid", %{body: html})
        redirect(conn, to: Routes.item_path(conn, :show, item_id))
      {:error, bid} ->
        item = Auction.get_item_with_bids(item_id)
        render(conn, AuctionWeb.ItemView, "show.html", item: item,
                                                       bid: convert_amount_to_dollars(bid))
    end
  end

  defp convert_amount_to_dollars(changeset) do
    update_in(changeset.changes.amount, &(&1 / 100))
  end
end