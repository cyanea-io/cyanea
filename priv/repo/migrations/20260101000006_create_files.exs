defmodule Cyanea.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :path, :string, null: false
      add :name, :string, null: false
      add :type, :string, null: false, default: "file"
      add :size, :bigint
      add :sha256, :string, size: 64
      add :mime_type, :string
      add :s3_key, :string
      add :metadata, :map, default: %{}

      add :repository_id, references(:repositories, type: :binary_id, on_delete: :delete_all), null: false
      add :commit_id, references(:commits, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:repository_id])
    create index(:files, [:commit_id])
    create index(:files, [:path])
    create index(:files, [:mime_type])
    create unique_index(:files, [:path, :commit_id])
  end
end
