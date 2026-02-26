defmodule CyaneaWeb.NotebookPresence do
  @moduledoc "Tracks which users are viewing/editing a notebook in real time."
  use Phoenix.Presence,
    otp_app: :cyanea,
    pubsub_server: Cyanea.PubSub
end
