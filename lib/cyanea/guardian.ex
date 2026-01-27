defmodule Cyanea.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication.
  """
  use Guardian, otp_app: :cyanea

  alias Cyanea.Accounts

  @doc """
  Encodes the user ID into the JWT subject claim.
  """
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  @doc """
  Decodes the JWT subject claim back into a user.
  """
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
