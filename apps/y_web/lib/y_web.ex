defmodule YWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use YWeb, :controller
      use YWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @spec router() :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @spec channel() ::
          {:use, [{:context, YWeb} | {:end_of_expression, [...]} | {:imports, [...]}, ...],
           [{:__aliases__, [...], [...]}, ...]}
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @spec controller() ::
          {:use, [{:context, YWeb} | {:end_of_expression, [...]} | {:imports, [...]}, ...],
           [{:__aliases__, [...], [...]}, ...]}
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: {YWeb.Layouts, :app}]

      import Plug.Conn

      unquote(html_helpers())
    end
  end

  @spec live_view() ::
          {:use, [{:context, YWeb} | {:end_of_expression, [...]} | {:imports, [...]}, ...],
           [{:__aliases__, [...], [...]}, ...]}
  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import YWeb.CoreComponents

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias YWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: YWeb.Endpoint,
        router: YWeb.Router,
        statics: YWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
