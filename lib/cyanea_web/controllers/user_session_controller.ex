defmodule CyaneaWeb.UserSessionController do
  use CyaneaWeb, :controller

  alias Cyanea.Accounts
  alias CyaneaWeb.UserAuth

  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> UserAuth.log_in_user(user, user_params)

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Signed out successfully.")
    |> UserAuth.log_out_user()
  end
end
