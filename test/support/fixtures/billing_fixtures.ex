defmodule Cyanea.BillingFixtures do
  @moduledoc """
  Test helpers for creating billing-related entities.
  """

  import Cyanea.AccountsFixtures

  alias Cyanea.Billing.Subscription
  alias Cyanea.Repo

  @doc """
  Creates a user with plan set to "pro".
  """
  def pro_user_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)

    user
    |> Ecto.Changeset.change(%{plan: "pro"})
    |> Repo.update!()
  end

  @doc """
  Creates a subscription record for the given owner.
  """
  def subscription_fixture(owner_type, owner_id, attrs \\ %{}) do
    defaults = %{
      stripe_subscription_id: "sub_test_#{System.unique_integer([:positive])}",
      stripe_price_id: "price_test_pro_user",
      status: "active",
      current_period_start: DateTime.utc_now() |> DateTime.add(-30, :day) |> DateTime.truncate(:second),
      current_period_end: DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.truncate(:second),
      quantity: 1,
      owner_type: owner_type,
      owner_id: owner_id
    }

    attrs = Map.merge(defaults, attrs)

    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert!()
  end
end
