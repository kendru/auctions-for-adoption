defmodule Auction.Auction do
  use Ecto.Schema
  import Ecto.Changeset
  import Auction.Formatting

  schema "auctions" do
    field :title, :string
    field :description, :string
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    has_many :item, Auction.Item
    belongs_to :user, Auction.User
    timestamps()
  end

  def changeset(bid, params \\ %{}) do
    bid
    |> cast(params, [:title, :description, :starts_at, :ends_at, :user_id])
    |> validate_required(:title)
    |> validate_length(:title, min: 3)
    |> validate_length(:description, max: 200)
    |> validate_change(:starts_at, &validate_future/2)
    |> validate_change(:ends_at, &validate_future/2)
    |> validate_after_start(:ends_at)
    |> assoc_constraint(:user)
  end

  defp validate_future(field, value) do
    case DateTime.compare(value, DateTime.utc_now()) do
      :lt -> [{field, "cannot be in the past"}]
      _ -> []
    end
  end

  defp validate_after_start(changeset, :ends_at, options \\ []) do
    starts_at_val = get_field(changeset, :starts_at, DateTime.utc_now())

    validate_change(changeset, :ends_at, fn :ends_at, ends_at_val ->
      case DateTime.compare(ends_at_val, starts_at_val) do
        :lt -> [ends_at: "must be after start"]
        _ -> []
      end
    end)
  end
end