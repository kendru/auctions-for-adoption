defmodule :"Elixir.Auction.Repo.Migrations.Add_auctions" do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :title, :string
      add :description, :string
      add :starts_at, :utc_datetime
      add :ends_at, :utc_datetime
      add :user_id, references(:users)
      timestamps()
    end

    create index(:auctions, [:user_id])
  end
end
