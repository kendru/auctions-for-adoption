defmodule AuctionWeb.GlobalHelpers do
  use Timex
  alias Auction.Formatting

  def integer_to_currency(cents), do: Formatting.integer_to_currency(cents)

  def formatted_datetime(datetime) do
    datetime
    |> Timex.format!("{YYYY}-{0M}-{0D} {h12}:{m}:{s} {am}")
  end
end