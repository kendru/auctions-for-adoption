defmodule Auction.Bid do
  use Ecto.Schema
  import Ecto.Changeset
  import Auction.Formatting

  schema "bids" do
    field :amount, :integer
    belongs_to :item, Auction.Item
    belongs_to :user, Auction.User
    timestamps()
  end

  def changeset(bid, params \\ %{}) do
    bid
    |> cast(params, [:amount, :item_id, :user_id])
    |> validate_required([:amount, :item_id, :user_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:user)
  end

  def changeset_with_prev_high_bid(bid, nil, params), do: changeset(bid, params)
  def changeset_with_prev_high_bid(bid, prev_high_bid, params) do
    bid
    |> cast(params, [:amount, :user_id])
    |> validate_highest_bid(prev_high_bid.amount)
    |> validate_no_double_bid(prev_high_bid.user_id)
    |> changeset(params)
  end

  defp validate_highest_bid(changeset, prev_amount) do
    validate_change(changeset, :amount, fn :amount, amount ->
      if amount > prev_amount do
        []
      else
        [amount: "I'm sorry, but you have been outbid! The current bid is: #{integer_to_currency(prev_amount)}"]
      end
    end)
  end

  defp validate_no_double_bid(changeset, prev_bidder_id) do
    validate_change(changeset, :user_id, fn :user_id, user_id ->
      if user_id == prev_bidder_id do
        [user_id: "You are the current high bidder. No need to bid again!"]
      else
        []
      end
    end)
  end
end