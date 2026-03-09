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
    get "/login", AuthController, :new
    post "/login", AuthController, :create
    delete "/logout", AuthController, :delete
  end

  # Authenticated routes
  scope "/", YWeb do
    pipe_through [:browser, YWeb.Plugs.RequireAuth]

    live "/feed", FeedLive, :index
    live "/p/:id", PostLive, :show
    live "/u/:username", ProfileLive, :show
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
