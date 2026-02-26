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

  IO.puts("Seeding complete!")
end
