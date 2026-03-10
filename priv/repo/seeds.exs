# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Cyanea.Repo.insert!(%Cyanea.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Cyanea.Repo
alias Cyanea.Accounts.User
alias Cyanea.Organizations.{Organization, Membership}
alias Cyanea.Spaces.Space

# Only seed in dev environment
if Mix.env() == :dev do
  IO.puts("Seeding development database...")

  # Create a demo user
  {:ok, demo_user} =
    %User{}
    |> User.changeset(%{
      email: "demo@cyanea.dev",
      username: "demo",
      name: "Demo User",
      password: "password123",
      bio: "A demo user for testing Cyanea",
      affiliation: "Cyanea Labs"
    })
    |> Repo.insert(on_conflict: :nothing)

  IO.puts("Created demo user: demo@cyanea.dev / password123")

  # Create site admin user (cyanea.bio owner)
  admin_result =
    %User{}
    |> User.changeset(%{
      email: "raffael.schneider@protonmail.com",
      username: "raskell",
      name: "Raffael Schneider",
      password: "Xk9$mW2vL#pQ7nR4!bYj"
    })
    |> Ecto.Changeset.put_change(:role, "admin")
    |> Ecto.Changeset.put_change(:confirmed_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> Repo.insert(on_conflict: :nothing)

  case admin_result do
    {:ok, %{id: nil}} ->
      # on_conflict: :nothing returned empty — user already exists, promote to admin
      if admin = Repo.get_by(User, email: "raffael.schneider@protonmail.com") do
        admin
        |> Ecto.Changeset.change(role: "admin")
        |> Repo.update!()

        IO.puts("Promoted existing user raskell to admin")
      end

    {:ok, _admin} ->
      IO.puts("Created site admin: raskell (role: admin)")

    {:error, changeset} ->
      IO.puts("Admin seed error: #{inspect(changeset.errors)}")
  end

  # Create a demo organization
  {:ok, demo_org} =
    %Organization{}
    |> Organization.changeset(%{
      name: "Cyanea Labs",
      slug: "cyanea-labs",
      description: "The official Cyanea demonstration organization",
      website: "https://cyanea.dev",
      location: "San Francisco, CA"
    })
    |> Repo.insert(on_conflict: :nothing)

  IO.puts("Created demo organization: cyanea-labs")

  # Add demo user as owner of the organization
  if demo_user.id && demo_org.id do
    %Membership{}
    |> Membership.changeset(%{
      user_id: demo_user.id,
      organization_id: demo_org.id,
      role: "owner"
    })
    |> Repo.insert(on_conflict: :nothing)

    IO.puts("Added demo user as owner of cyanea-labs")

    # Create a demo space
    %Space{}
    |> Space.changeset(%{
      name: "Example Dataset",
      slug: "example-dataset",
      description: "An example dataset demonstrating Cyanea's features",
      visibility: "public",
      license: "cc-by-4.0",
      owner_type: "organization",
      owner_id: demo_org.id,
      tags: ["example", "demo", "genomics"]
    })
    |> Repo.insert(on_conflict: :nothing)

    IO.puts("Created demo space: cyanea-labs/example-dataset")
  end

  # Seed Learn curriculum (tracks, paths, units)
  IO.puts("\nSeeding Learn curriculum...")

  # Ensure we have the user's ID (on_conflict: :nothing may return nil id)
  seed_user = demo_user.id && demo_user || Repo.get_by!(User, email: "demo@cyanea.dev")

  case Cyanea.Learn.Seed.run(owner_type: "user", owner_id: seed_user.id) do
    {:ok, summary} ->
      IO.puts("  Tracks: #{summary.tracks} created")
      IO.puts("  Paths: #{summary.paths} created")
      IO.puts("  Units: #{summary.units} imported")

      if summary.skipped > 0 do
        IO.puts("  Skipped: #{summary.skipped} (already exist or missing files)")
      end

    {:error, reason} ->
      IO.puts("  Learn seed failed: #{inspect(reason)}")
  end

  IO.puts("\nSeeding complete!")
end
