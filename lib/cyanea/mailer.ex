defmodule Cyanea.Mailer do
  @moduledoc """
  Swoosh mailer for transactional email delivery.
  """
  use Swoosh.Mailer, otp_app: :cyanea
end
