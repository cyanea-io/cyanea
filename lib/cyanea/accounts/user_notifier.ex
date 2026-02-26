defmodule Cyanea.Accounts.UserNotifier do
  @moduledoc """
  Builds transactional email messages for user account operations.

  Each function returns a `Swoosh.Email` struct ready for delivery.
  Actual sending is handled by `Cyanea.Workers.EmailWorker` via Oban.
  """
  import Swoosh.Email

  @from_name "Cyanea"

  defp base_email do
    {from_name, from_address} = Application.get_env(:cyanea, :mailer_from, {@from_name, "noreply@cyanea.dev"})

    new()
    |> from({from_name, from_address})
  end

  @doc """
  Builds an email confirmation message.
  """
  def confirmation_email(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Confirm your Cyanea account")
    |> text_body("""
    Hi #{user.name || user.username},

    Please confirm your email address by visiting the URL below:

    #{url}

    This link will expire in 24 hours.

    If you didn't create an account on Cyanea, please ignore this email.
    """)
  end

  @doc """
  Builds a password reset message.
  """
  def reset_password_email(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Reset your Cyanea password")
    |> text_body("""
    Hi #{user.name || user.username},

    You can reset your password by visiting the URL below:

    #{url}

    This link will expire in 24 hours.

    If you didn't request a password reset, please ignore this email.
    """)
  end
end
