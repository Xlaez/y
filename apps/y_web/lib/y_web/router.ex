defmodule YWeb.Router do
  use YWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :fetch_flash
    plug :put_root_layout, html: {YWeb.Layouts, :root}
    plug :put_layout, html: {YWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug YWeb.Plugs.SecurityHeaders
    plug YWeb.Plugs.SanitiseParams
    plug YWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug YWeb.Plugs.SecurityHeaders
    plug YWeb.Plugs.RateLimit
  end

  scope "/", YWeb do
    pipe_through :browser

    get "/", PageController, :home
    
    live_session :redirect_if_authenticated,
      on_mount: [{YWeb.Plugs.Auth, :mount_current_user}, {YWeb.Plugs.Auth, :redirect_if_authenticated}] do
      live "/login", SessionLive, :index
      live "/signup", RegistrationLive, :index
      live "/forgot-password", PasswordResetLive, :index
    end
    
    post "/login", AuthController, :create
    delete "/logout", AuthController, :delete
    post "/register_complete", AuthController, :register_complete
  end

  scope "/onboarding", YWeb do
    pipe_through :browser
    
    live_session :onboarding,
      on_mount: [{YWeb.Plugs.Auth, :mount_current_user}] do
      live "/seed-phrase", SeedPhraseLive, :index
    end
  end

  scope "/", YWeb do
    pipe_through :browser

    live_session :require_authenticated_user,
      on_mount: [{YWeb.Plugs.Auth, :mount_current_user}, {YWeb.Plugs.Auth, :ensure_authenticated}] do
      live "/home", HomeLive, :index
      live "/explore", ExploreLive, :index
      live "/notifications", NotificationsLive, :index
      live "/bookmarks", BookmarksLive, :index
      live "/settings", SettingsLive, :index
      live "/settings/muted", MutedAccountsLive, :index
      live "/settings/blocked", BlockedAccountsLive, :index
      live "/:username", ProfileLive, :show
      live "/:username/take/:id", TakeLive, :show
      live "/:username/followers", ConnectionsLive, :followers
      live "/:username/following", ConnectionsLive, :following

      post "/follows", FollowController, :create
      delete "/follows/:followee_id", FollowController, :delete
      post "/blocks", BlockController, :create
      delete "/blocks/:blocked_id", BlockController, :delete
      post "/mutes", MuteController, :create
      delete "/mutes/:muted_id", MuteController, :delete
    end
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
