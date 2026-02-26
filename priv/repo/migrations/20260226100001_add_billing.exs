defmodule Cyanea.Repo.Migrations.AddBilling do
  use Ecto.Migration

  def change do
    # Add billing fields to users
    alter table(:users) do
      add :plan, :string, default: "free", null: false
      add :stripe_customer_id, :string
    end

    create index(:users, [:stripe_customer_id], unique: true, where: "stripe_customer_id IS NOT NULL")

    # Add billing fields to organizations
    alter table(:organizations) do
      add :plan, :string, default: "free", null: false
      add :stripe_customer_id, :string
    end

    create index(:organizations, [:stripe_customer_id],
             unique: true,
             where: "stripe_customer_id IS NOT NULL"
           )

    # Subscriptions table — Stripe state of truth
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :stripe_subscription_id, :string, null: false
      add :stripe_price_id, :string, null: false
      add :status, :string, null: false
      add :current_period_start, :utc_datetime
      add :current_period_end, :utc_datetime
      add :cancel_at, :utc_datetime
      add :canceled_at, :utc_datetime
      add :quantity, :integer, default: 1
      add :owner_type, :string, null: false
      add :owner_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:subscriptions, [:stripe_subscription_id])
    create index(:subscriptions, [:owner_type, :owner_id])

    # Storage usage cache
    create table(:storage_usage, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :owner_type, :string, null: false
      add :owner_id, :binary_id, null: false
      add :bytes_used, :bigint, default: 0, null: false
      add :computed_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:storage_usage, [:owner_type, :owner_id])
  end
end
