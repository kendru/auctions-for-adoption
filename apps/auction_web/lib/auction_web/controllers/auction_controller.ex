defmodule AuctionWeb.AuctionController do
  use AuctionWeb, :controller
  plug AuctionWeb.Plugs.RequireLoggedInUser when action in [:new, :create]

  def index(conn, _params) do
    auctions = Auction.list_auctions()
    render conn, "index.html", auctions: auctions
  end

  def show(conn, %{"id" => id}) do
    auction = Auction.get_auction(id)
    # item = Auction.get_item_with_bids(id)
    # bid = Auction.new_bid()
    render(conn, "show.html", auction: auction)
  end

  def new(conn, _params) do
    auction = Auction.new_auction()
    render conn, "new.html", auction: auction
  end

  def create(conn, %{"auction" => auction_params}) do
    user_id = conn.assigns.current_user.id
    result = auction_params
    |> Map.put("user_id", user_id)
    |> Auction.insert_auction()

    case result do
      {:ok, auction} -> redirect conn, to: Routes.auction_path(conn, :show, auction)
      {:error, auction} -> render conn, "new.html", auction: auction
    end
  end

  # def edit(conn, %{"id" => id}) do
  #   item = Auction.edit_item(id)
  #   render conn, "edit.html", item: item
  # end

  # def update(conn, %{"id" => id, "item" => item_params}) do
  #   item = Auction.get_item(id)
  #   case Auction.update_item(item, item_params) do
  #     {:ok, item} -> redirect conn, to: Routes.item_path(conn, :show, item)
  #     {:error, item} -> render conn, "edit.html", item: item
  #   end
  # end
end