defmodule Auction.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :title, :string
    field :description, :string
    field :ends_at, :utc_datetime
    belongs_to :auction, Auction.Auction
    has_many :bids, Auction.Bid
    timestamps()
  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [:title, :description, :auction_id])
    |> validate_required(:title)
    |> validate_length(:title, min: 3)
    |> validate_length(:description, max: 200)
    |> assoc_constraint(:auction)
  end
end