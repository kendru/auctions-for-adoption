defmodule Auction.Repo.Migrations.AddAuctionAssocToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :auction_id, references(:auctions)
    end

    create index(:items, [:auction_id])
  end
end
