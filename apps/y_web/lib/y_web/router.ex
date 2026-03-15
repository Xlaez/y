defmodule YWeb.Router do
  use YWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {YWeb.Layouts, :root}
    plug :put_layout, html: {YWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug YWeb.Plugs.SecurityHeaders
    plug YWeb.Plugs.SanitiseParams
    plug YWeb.Plugs.LoadUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug YWeb.Plugs.SecurityHeaders
    plug YWeb.Plugs.RateLimit
  end

  scope "/", YWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/login", SessionLive, :index
    live "/signup", RegistrationLive, :index
    live "/forgot-password", PasswordResetLive, :index
  end

  scope "/onboarding", YWeb do
    pipe_through :browser
    live "/seed-phrase", SeedPhraseLive, :index
  end

  scope "/", YWeb do
    pipe_through :browser

    live "/home", HomeLive, :index
    live "/explore", ExploreLive, :index
    live "/notifications", NotificationsLive, :index
    live "/bookmarks", BookmarksLive, :index
    live "/settings", SettingsLive, :index
    live "/settings/muted", MutedAccountsLive, :index
    live "/settings/blocked", BlockedAccountsLive, :index
    live "/:username", ProfileLive, :show
    live "/:username/followers", ConnectionsLive, :followers
    live "/:username/following", ConnectionsLive, :following
  end

  # Other scopes may use custom stacks.
  # scope "/api", YWeb do
  #   pipe_through :api
  # end

  if Application.compile_env(:y_web, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: YWeb.Telemetry
    end
  end
end
