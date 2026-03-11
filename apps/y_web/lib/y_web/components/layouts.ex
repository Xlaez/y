defmodule YWeb.Layouts do
  use YWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the standard app layout (for unauthenticated pages).
  """
  attr :flash, :map, required: true
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="min-h-screen bg-brand-bg">
      <YWeb.Layouts.toast_group flash={@flash} />
      {@inner_content}
    </main>
    """
  end

  @doc """
  Renders the authenticated shell layout.
  """
  attr :current_user, :map, required: true
  attr :active_tab, :atom, default: :home
  attr :flash, :map, required: true
  slot :inner_block, required: true

  def authenticated(assigns) do
    assigns =
      assigns
      |> Map.put_new(:active_tab, :home)
      |> Map.put_new(:current_user, YWeb.DummyData.current_user())
      |> Map.put_new(:flash, %{})

    ~H"""
    <div class="flex min-h-screen bg-brand-bg text-body-text font-inter antialiased">
      <YWeb.Layouts.toast_group flash={@flash} />
      <!-- Left Sidebar - Desktop -->
      <aside class="fixed inset-y-0 left-0 hidden w-20 xl:w-64 border-r border-brand-border lg:block bg-brand-bg z-50">
        <div class="flex flex-col h-full px-2 xl:px-4 py-6">
          <div class="px-4 mb-8">
            <h1 class="text-accent text-3xl xl:text-4xl font-black text-center xl:text-left select-none">y</h1>
          </div>

          <nav class="flex-1 space-y-2">
            <.nav_item to="/home" icon="hero-home" label="Home" active={@active_tab == :home} />
            <.nav_item to="/explore" icon="hero-magnifying-glass" label="Explore" active={@active_tab == :explore} />
            <.nav_item
              to="/notifications"
              icon="hero-bell"
              label="Notifications"
              active={@active_tab == :notifications}
              badge={12}
            />
            <.nav_item to="/bookmarks" icon="hero-bookmark" label="Bookmarks" active={@active_tab == :bookmarks} />
            <.nav_item
              to={"/#{@current_user.username}"}
              icon="hero-user"
              label="Profile"
              active={@active_tab == :profile}
            />
            <.nav_item to="/settings" icon="hero-cog-6-tooth" label="Settings" active={@active_tab == :settings} />
          </nav>

          <button class="w-full bg-accent hover:bg-[#CE35E0] text-white font-bold rounded-full py-3 mt-4 shadow-lg shadow-accent/20 transition-all duration-150 active:scale-[0.98] flex items-center justify-center">
            <span class="xl:hidden hero-pencil size-6"></span>
            <span class="hidden xl:block">New Take</span>
          </button>

          <div class="mt-auto pt-6 border-t border-brand-border">
            <.user_row user={@current_user} />
          </div>
        </div>
      </aside>

      <!-- Main Content Area -->
      <main class="flex-1 lg:ml-20 xl:ml-64 min-h-screen pb-20 lg:pb-0">
        <div class="max-w-[600px] mx-auto min-h-screen border-x border-brand-border/30 bg-brand-bg shadow-2xl shadow-black/50">
          {@inner_content}
        </div>
      </main>

      <!-- Mobile Bottom Nav -->
      <nav class="fixed bottom-0 inset-x-0 h-16 bg-brand-bg/80 backdrop-blur-md border-t border-brand-border flex items-center justify-around lg:hidden z-50">
        <.mobile_nav_item to="/home" icon="hero-home" active={@active_tab == :home} />
        <.mobile_nav_item to="/explore" icon="hero-magnifying-glass" active={@active_tab == :explore} />
        <.mobile_nav_item
          to="/notifications"
          icon="hero-bell"
          active={@active_tab == :notifications}
          badge={12}
        />
        <.mobile_nav_item to="/settings" icon="hero-cog-6-tooth" active={@active_tab == :settings} />
      </nav>
    </div>
    """
  end

  defp nav_item(assigns) do
    ~H"""
    <.link
      patch={@to}
      class={[
        "flex items-center gap-4 px-4 py-3 rounded-full transition-all duration-150 group",
        if(@active, do: "text-accent font-bold", else: "text-body-text hover:bg-brand-surface")
      ]}
    >
      <div class="relative">
        <span class={[@icon, "size-7 transition-transform group-hover:scale-110", if(@active, do: "text-accent", else: "text-body-text")]}></span>
        <%= if assigns[:badge] && @badge > 0 do %>
          <span class="absolute -top-1.5 -right-1.5 bg-error text-white text-[10px] font-bold rounded-full px-1.5 py-0.5 border border-brand-bg">
            <%= @badge %>
          </span>
        <% end %>
      </div>
      <span class="text-xl hidden xl:block"><%= @label %></span>
    </.link>
    """
  end

  defp mobile_nav_item(assigns) do
    ~H"""
    <.link
      patch={@to}
      class={[
        "relative p-2 rounded-full transition-all duration-150 active:scale-90",
        if(@active, do: "text-accent", else: "text-body-text")
      ]}
    >
      <span class={[@icon, "size-7"]}></span>
      <%= if assigns[:badge] && @badge > 0 do %>
        <span class="absolute top-1 right-1 bg-error text-white text-[10px] font-bold rounded-full px-1.5 py-0.5 border border-brand-bg">
          <%= @badge %>
        </span>
      <% end %>
    </.link>
    """
  end

  defp user_row(assigns) do
    ~H"""
    <div class="flex items-center gap-3 px-3 py-3 rounded-full hover:bg-brand-surface cursor-pointer transition-all duration-150 group">
      <.bitmoji user={@user} size="sm" />
      <div class="flex-1 min-w-0 hidden xl:block">
        <p class="text-white font-bold truncate text-sm"><%= @user.username %></p>
        <p class="text-muted text-xs truncate"><%= @user.handle %></p>
      </div>
      <span class="hero-ellipsis-horizontal size-5 text-muted group-hover:text-body-text ml-auto hidden xl:block">
      </span>
    </div>
    """
  end

  attr :user, :map, required: true
  attr :size, :string, default: "md", values: ["sm", "md", "lg", "xl"]

  def bitmoji(assigns) do
    size_classes = %{
      "sm" => "size-10 text-xs",
      "md" => "size-12 text-sm",
      "lg" => "size-16 text-xl",
      "xl" => "size-20 text-2xl"
    }

    assigns = assign(assigns, :size_class, size_classes[assigns.size])

    ~H"""
    <div
      class={["shrink-0 rounded-full flex items-center justify-center font-bold text-white shadow-inner", @size_class]}
      style={"background-color: #{@user.bitmoji_color};"}
    >
      <%= YWeb.Helpers.Bitmoji.initials(@user.username) %>
    </div>
    """
  end

  @doc """
  Renders a single take card.
  """
  attr :take, :map, required: true

  def take_card(assigns) do
    ~H"""
    <div class="px-4 py-4 hover:bg-brand-surface/40 transition-colors cursor-pointer group">
      <div class="flex gap-3">
        <.bitmoji user={@take.user} size="md" />

        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-1.5 mb-0.5">
            <span class="text-white font-bold text-sm hover:underline"><%= @take.user.username %></span>
            <span class="text-muted text-sm"><%= @take.user.handle %></span>
            <span class="text-muted text-sm">· <%= @take.inserted_at %></span>
          </div>

          <%= if @take.type == :opinion do %>
            <p class="text-accent2 text-sm mb-1">
              Replying to <span class="hover:underline cursor-pointer"><%= @take.parent.user.handle %></span>
            </p>
          <% end %>

          <p class="text-body-text text-base leading-relaxed break-words">
            <%= @take.body %>
          </p>

          <%= if @take.type in [:retake, :opinion] do %>
            <div class="mt-3 border border-brand-border rounded-xl p-3 bg-brand-bg/50 hover:bg-brand-bg transition-colors">
              <div class="flex items-center gap-2 mb-1">
                <.bitmoji user={@take.parent.user} size="sm" />
                <span class="text-white font-bold text-sm"><%= @take.parent.user.username %></span>
                <span class="text-muted text-sm"><%= @take.parent.user.handle %></span>
              </div>
              <p class="text-body-text text-sm leading-relaxed truncate">
                <%= @take.parent.body %>
              </p>
            </div>
          <% end %>

          <div class="flex items-center justify-between mt-4 max-w-sm">
            <.action_button
              icon="hero-chat-bubble-left"
              count={@take.opinion_count}
              hover_class="hover:text-accent hover:bg-accent/10"
            />
            <.action_button
              icon="hero-arrow-path"
              count={@take.retake_count}
              hover_class="hover:text-accent2 hover:bg-accent2/10"
            />
            <.action_button
              icon="hero-heart"
              count={@take.agreed_count}
              hover_class="hover:text-error hover:bg-error/10"
            />
            <.action_button
              icon="hero-bookmark"
              hover_class="hover:text-warning hover:bg-warning/10"
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp action_button(assigns) do
    ~H"""
    <div class={["flex items-center gap-2 group/btn transition-colors text-muted", assigns[:hover_class]]}>
      <div class="p-2 rounded-full group-hover/btn:bg-current/10">
        <span class={[assigns.icon, "size-5"]}></span>
      </div>
      <%= if assigns[:count] do %>
        <span class="text-xs font-medium"><%= assigns.count %></span>
      <% end %>
    </div>
    """
  end

  @doc """
  Subtle toast notification.
  """
  attr :flash, :map, required: true

  def toast_group(assigns) do
    ~H"""
    <div id="toast-group" class="fixed bottom-6 right-6 z-[100] flex flex-col gap-3 items-end pointer-events-none">
      <%= for {kind, message} <- @flash do %>
        <.toast kind={kind} message={message} />
      <% end %>
    </div>
    """
  end

  defp toast(assigns) do
    kind = assigns.kind
    message = assigns.message

    {icon, color} = case kind do
      "info" -> {"hero-information-circle", "text-accent2"}
      "error" -> {"hero-x-circle", "text-error"}
      _ -> {"hero-bell", "text-accent"}
    end

    assigns = 
      assigns 
      |> assign(:icon, icon)
      |> assign(:color, color)
      |> assign(:message, message)

    ~H"""
    <div 
      phx-mounted={show("#toast")}
      class="pointer-events-auto bg-brand-surface border border-brand-border rounded-xl px-4 py-3 shadow-2xl flex items-center gap-3 animate-in fade-in slide-in-from-right-10 duration-300"
    >
      <span class={[@icon, @color, "size-5"]}></span>
      <span class="text-body-text text-sm font-medium"><%= @message %></span>
      <button class="ml-2 text-muted hover:text-white transition-colors">
        <span class="hero-x-mark size-4"></span>
      </button>
    </div>
    """
  end
end
