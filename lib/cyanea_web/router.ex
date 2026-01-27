defmodule CyaneaWeb.Router do
  use CyaneaWeb, :router

  import CyaneaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CyaneaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", CyaneaWeb do
    pipe_through :browser

    live "/", HomeLive, :index
  end

  # Authentication routes (to be implemented)
  scope "/auth", CyaneaWeb do
    pipe_through :browser

    # Placeholder routes - will be implemented
    live "/login", AuthLive.Login, :new
    live "/register", AuthLive.Register, :new
  end

  # Development routes
  if Application.compile_env(:cyanea, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CyaneaWeb.Telemetry
    end
  end
end
