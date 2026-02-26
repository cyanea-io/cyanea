defmodule Cyanea.Notebooks.ExecutionResult do
  @moduledoc "Persisted server-side execution result for a notebook cell."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notebook_execution_results" do
    field :cell_id, :string
    field :status, :string
    field :output, :map

    belongs_to :notebook, Cyanea.Notebooks.Notebook
    belongs_to :user, Cyanea.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:cell_id, :status, :output, :notebook_id, :user_id])
    |> validate_required([:cell_id, :status, :notebook_id])
    |> validate_inclusion(:status, ~w(completed error timeout))
  end
end
