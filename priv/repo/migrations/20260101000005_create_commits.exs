defmodule Cyanea.Repo.Migrations.CreateCommits do
  use Ecto.Migration

  def change do
    create table(:commits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sha, :string, null: false, size: 40
      add :message, :text, null: false
      add :parent_sha, :string, size: 40
      add :tree_sha, :string, size: 40
      add :authored_at, :utc_datetime

      add :repository_id, references(:repositories, type: :binary_id, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:commits, [:repository_id])
    create index(:commits, [:author_id])
    create index(:commits, [:authored_at])
    create unique_index(:commits, [:sha, :repository_id])
  end
end
