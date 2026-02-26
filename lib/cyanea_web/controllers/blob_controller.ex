defmodule CyaneaWeb.BlobController do
  use CyaneaWeb, :controller

  alias Cyanea.Blobs

  def download(conn, %{"id" => id}) do
    blob = Blobs.get_blob!(id)

    case Blobs.download_url(blob) do
      {:ok, url} ->
        redirect(conn, external: url)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not generate download URL.")
        |> redirect(to: ~p"/explore")
    end
  end
end
