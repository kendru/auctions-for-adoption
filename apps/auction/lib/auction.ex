defmodule Auction do
  import Ecto.Query
  alias Auction.{Repo, Auction, Item, User, Bid, Password}

  @repo Repo

  # AUCTIONS
  def new_auction, do: Auction.changeset(%Auction{})

  def list_auctions, do: @repo.all(Auction)

  def get_auction(id), do: @repo.get!(Auction, id)

  def insert_auction(attrs) do
    %Auction{}
    |> Auction.changeset(attrs)
    |> @repo.insert()
  end

  # ITEMS
  def new_item, do: Item.changeset(%Item{})

  def list_items, do: @repo.all(Item)

  def get_item(id), do: @repo.get!(Item, id)

  def get_item_by(attrs), do: @repo.get_by(Item, attrs)

  def get_item_with_bids(id) do
    id
    |> get_item()
    |> @repo.preload(bids: from(b in Bid, order_by: [desc: b.inserted_at]))
    |> @repo.preload(bids: [:user])
  end

  def insert_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> @repo.insert()
  end

  def edit_item(id) do
    get_item(id)
    |> Item.changeset()
  end

  def update_item(%Item{} = item, updates) do
    item
    |> Item.changeset(updates)
    |> @repo.update()
  end

  def delete_item(%Item{} = item), do: @repo.delete(item)

  # BIDS
  def new_bid, do: Bid.changeset(%Bid{})

  def insert_bid(%{item_id: item_id, amount: amount} = params) do
    highest_bid_query =
      from b in Bid,
      where: b.item_id == ^item_id,
      order_by: [desc: b.amount],
      limit: 1
    prev_high_bid = @repo.one(highest_bid_query)

    %Bid{}
    |> Bid.changeset_with_prev_high_bid(prev_high_bid, params)
    |> @repo.insert()
  end

  def get_bids_for_user(%User{} = user) do
    query =
      from b in Bid,
      where: b.user_id == ^user.id,
      order_by: [desc: :inserted_at],
      preload: :item,
      limit: 10
    @repo.all(query)
  end

  # USERS
  def new_user, do: User.changeset_with_password(%User{})

  def get_user(id), do: @repo.get!(User, id)

  def insert_user(attrs) do
    %User{}
    |> User.changeset_with_password(attrs)
    |> @repo.insert()
  end

  def get_user_by_username_and_password(username, password) do
    with user when not is_nil(user) <- @repo.get_by(User, %{username: username}),
         true <- Password.verify_with_hash(password, user.hashed_password) do
      user
    else
      _ -> Password.dummy_verify
    end
  end

  def with_user_auctions(user) do
    user
    |> @repo.preload(:auctions)
  end
end
