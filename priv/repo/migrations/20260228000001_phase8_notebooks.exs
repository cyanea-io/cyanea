defmodule Cyanea.Repo.Migrations.Phase8Notebooks do
  use Ecto.Migration

  def change do
    # Notebook version snapshots (immutable, sequential per notebook)
    create table(:notebook_versions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :integer, null: false
      add :label, :string
      add :content, :map, null: false
      add :content_hash, :string
      add :trigger, :string, null: false

      add :notebook_id, references(:notebooks, type: :binary_id, on_delete: :delete_all),
        null: false

      add :author_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      add :created_at, :utc_datetime, null: false
    end

    create index(:notebook_versions, [:notebook_id])
    create index(:notebook_versions, [:author_id])
    create unique_index(:notebook_versions, [:notebook_id, :number])

    # Persisted server-side execution results (upsert per cell)
    create table(:notebook_execution_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cell_id, :string, null: false
      add :status, :string, null: false
      add :output, :map

      add :notebook_id, references(:notebooks, type: :binary_id, on_delete: :delete_all),
        null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:notebook_execution_results, [:notebook_id])
    create unique_index(:notebook_execution_results, [:notebook_id, :cell_id])
  end
end
