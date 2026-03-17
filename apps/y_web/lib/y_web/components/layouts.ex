defmodule YWeb.Layouts do
  use YWeb, :html

  embed_templates "layouts/*"

  @spec app(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders the standard app layout (for unauthenticated pages).
  """
  attr :flash, :map, required: true
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="min-h-screen bg-y-bg">
      <YWeb.Layouts.toast_group flash={@flash} />
      {@inner_content}
    </main>
    """
  end

  @spec authenticated(map()) :: Phoenix.LiveView.Rendered.t()
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
    <div class="flex min-h-screen bg-y-bg text-y-text font-inter antialiased">
      <YWeb.Layouts.toast_group flash={@flash} />

      <!-- Left Sidebar: Fixed 256px -->
      <aside class="fixed inset-y-0 left-0 hidden w-64 border-r border-y-border md:flex flex-col bg-y-bg z-50">
        <div class="flex flex-col h-full px-4 py-6">
          <div class="px-4 mb-8">
            <h1 class="text-y-white text-4xl font-black text-left select-none">y</h1>
          </div>

          <nav class="flex-1 space-y-2">
            <.nav_item to="/home" icon="hero-home" label="Feed" active={@active_tab == :home} />
            <.nav_item to="/explore" icon="hero-magnifying-glass" label="Explore" active={@active_tab == :explore} />
            <.nav_item
              to="/notifications"
              icon="hero-bell"
              label="Notifications"
              active={@active_tab == :notifications}
              badge={12}
            />
            <.nav_item to="/bookmarks" icon="hero-bookmark" label="Saves" active={@active_tab == :bookmarks} />
            <.nav_item
              to={"/#{@current_user.username}"}
              icon="hero-user"
              label="Profile"
              active={@active_tab == :profile}
            />
            <.nav_item to="/settings" icon="hero-cog-6-tooth" label="Preferences" active={@active_tab == :settings} />
          </nav>

          <button
            phx-click={YWeb.CoreComponents.show_modal("create-take-modal")}
            class="w-full bg-white text-black font-bold rounded-full py-3 mt-4 hover:bg-[#E5E5E7] transition-all duration-150 active:scale-[0.98] flex items-center justify-center"
          >
            <span class="lg:hidden hero-pencil size-6"></span>
            <span class="hidden lg:block">Share a take</span>
          </button>

          <div class="mt-auto pt-6 border-t border-y-border">
            <.user_row user={@current_user} />
          </div>
        </div>
      </aside>

      <!-- Centre Feed: fluid, constrained -->
      <main class="flex-1 md:ml-64 lg:mr-[300px] min-h-screen pb-20 md:pb-0 lg:border-r lg:border-y-border">
        <div class="w-full max-w-[600px] mx-auto min-h-screen border-x border-y-border lg:border-x-0">
          {@inner_content}
        </div>
      </main>

      <!-- Right Panel: fixed 300px -->
      <aside class="fixed right-0 top-0 hidden lg:block h-screen w-[300px] px-4 py-6 overflow-y-auto z-10">
        <.right_panel />
      </aside>

      <!-- Mobile Bottom Nav -->
      <nav class="fixed bottom-0 inset-x-0 h-16 bg-y-bg/80 backdrop-blur-md border-t border-y-border flex items-center justify-around lg:hidden z-50">
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

      <.modal id="create-take-modal">
        <.take_composer
          id="take-composer-modal"
          current_user={@current_user}
          placeholder="What is happening?!"
          submit_label="Share"
          submit_event="share_take"
        >
          <:header>
            <div class="flex items-center justify-between mb-4">
              <button
                type="button"
                phx-click={YWeb.CoreComponents.hide_modal("create-take-modal")}
                class="p-2 hover:bg-y-hover rounded-full transition-colors"
              >
                <span class="hero-x-mark size-5 text-white"></span>
              </button>
              <button class="text-y-opinion font-bold text-sm hover:underline px-2">Drafts</button>
            </div>
          </:header>
        </.take_composer>
      </.modal>
    </div>
    """
  end

  @spec take_composer(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders the interactive take composer.
  """
  attr :id, :string, required: true
  attr :current_user, :map, required: true
  attr :placeholder, :string, default: "What is happening?!"
  attr :submit_label, :string, default: "Share"
  attr :submit_event, :string, default: "share_take"
  attr :change_event, :string, default: nil
  attr :value, :string, default: ""
  attr :class, :string, default: "px-6 py-4"

  slot :header

  def take_composer(assigns) do
    ~H"""
    <div id={@id} phx-hook="TakeComposer" class={["flex flex-col min-h-[150px]", @class]}>
      <%= render_slot(@header) %>
      <div class="flex gap-4">
        <div class="shrink-0 pt-1">
          <.bitmoji user={@current_user} size="md" />
        </div>
        <div class="flex-1">
          <form phx-submit={@submit_event} phx-change={@change_event}>
            <textarea
              data-take-input
              name="body"
              placeholder={@placeholder}
              class="w-full bg-transparent border-none text-y-text text-xl resize-none focus:ring-0 focus:outline-none p-0 placeholder-y-muted h-32"
              autofocus
              value={@value}
            ><%= @value %></textarea>

            <div class="border-t border-y-border mt-4 pt-4 flex items-center justify-between">
              <div class="flex items-center gap-1">
                <button type="button" class="p-2 hover:bg-y-opinion/10 rounded-full transition-colors group">
                  <span class="hero-photo size-5 text-y-opinion"></span>
                </button>
                <button type="button" class="p-2 hover:bg-y-opinion/10 rounded-full transition-colors group text-y-opinion">
                  <span class="hero-list-bullet size-5"></span>
                </button>
                <button type="button" class="p-2 hover:bg-y-opinion/10 rounded-full transition-colors group text-y-opinion">
                  <span class="hero-face-smile size-5"></span>
                </button>
                <button type="button" class="p-2 hover:bg-y-opinion/10 rounded-full transition-colors group text-y-opinion/50 cursor-not-allowed">
                  <span class="hero-calendar-days size-5"></span>
                </button>
                <button type="button" class="p-2 hover:bg-y-opinion/10 rounded-full transition-colors group text-y-opinion/50 cursor-not-allowed">
                  <span class="hero-map-pin size-5"></span>
                </button>
              </div>

              <div class="flex items-center gap-4">
                <div class="relative size-8 flex items-center justify-center">
                  <svg class="size-full -rotate-90" viewBox="0 0 32 32">
                    <circle
                      class="text-y-border stroke-current"
                      stroke-width="2"
                      fill="transparent"
                      r="14"
                      cx="16"
                      cy="16"
                    />
                    <circle
                      data-progress-circle
                      class="transition-all duration-200"
                      stroke="#F5F5F5"
                      stroke-width="2"
                      stroke-linecap="round"
                      fill="transparent"
                      r="14"
                      cx="16"
                      cy="16"
                    />
                  </svg>
                  <span data-counter class="absolute text-[10px] font-medium hidden"></span>
                </div>

                <button
                  data-share-button
                  type="submit"
                  class="bg-white text-black px-6 py-2 rounded-full font-bold hover:bg-[#E5E5E7] transition-all disabled:opacity-50"
                >
                  <%= @submit_label %>
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  defp nav_item(assigns) do
    ~H"""
    <.link
      patch={@to}
      class={[
        "flex items-center gap-4 px-4 py-3 rounded-full transition-all duration-150 group",
        if(@active, do: "text-white font-semibold", else: "text-y-text hover:bg-y-hover")
      ]}
    >
      <div class="relative">
        <span class={[@icon, "size-7 transition-transform group-hover:scale-110", if(@active, do: "text-white", else: "text-y-text")]}></span>
        <%= if assigns[:badge] && @badge > 0 do %>
          <span class="absolute -top-1.5 -right-1.5 bg-y-agree text-white text-[10px] font-bold rounded-full px-1.5 py-0.5 border border-y-bg">
            <%= @badge %>
          </span>
        <% end %>
      </div>
      <span class="text-xl hidden lg:block"><%= @label %></span>
    </.link>
    """
  end

  defp mobile_nav_item(assigns) do
    ~H"""
    <.link
      patch={@to}
      class={[
        "relative p-2 rounded-full transition-all duration-150 active:scale-90",
        if(@active, do: "text-white", else: "text-y-text")
      ]}
    >
      <span class={[@icon, "size-7"]}></span>
      <%= if assigns[:badge] && @badge > 0 do %>
        <span class="absolute top-1 right-1 bg-y-agree text-white text-[10px] font-bold rounded-full px-1.5 py-0.5 border border-y-bg">
          <%= @badge %>
        </span>
      <% end %>
    </.link>
    """
  end

  defp user_row(assigns) do
    ~H"""
    <div class="flex items-center justify-between px-3 py-3 rounded-full hover:bg-y-hover transition-all duration-150 group px-3">
      <div class="flex items-center gap-3 flex-1 min-w-0">
        <.bitmoji user={@user} size="sm" />
        <div class="flex-1 min-w-0 hidden xl:block text-left">
          <p class="text-y-text font-medium truncate text-sm"><%= @user.username %></p>
          <p class="text-y-muted text-xs truncate"><%= @user.handle %></p>
        </div>
      </div>
      <.link
        href={~p"/logout"}
        method="delete"
        class="text-y-muted hover:text-y-agree transition-colors xl:block hidden"
        title="Sign out"
      >
        <span class="hero-arrow-right-start-on-rectangle size-5"></span>
      </.link>
    </div>
    <div class="xl:hidden flex justify-center py-2">
       <.link
          href={~p"/logout"}
          method="delete"
          class="text-y-muted hover:text-y-agree transition-colors"
          title="Sign out"
        >
          <span class="hero-arrow-right-start-on-rectangle size-6"></span>
        </.link>
    </div>
    """
  end

  defp right_panel(assigns) do
    ~H"""
    <div class="flex flex-col gap-6 pt-2">
      <.who_to_follow_widget />
      <.trending_widget />
    </div>
    """
  end

  defp who_to_follow_widget(assigns) do
    assigns = assign(assigns, :users, Enum.take(YWeb.DummyData.users(), 3))

    ~H"""
    <div class="bg-y-surface rounded-2xl overflow-hidden">
      <div class="px-4 py-3 border-b border-y-border">
        <h3 class="text-y-text font-semibold text-[15px]">Who to follow</h3>
      </div>
      <div class="divide-y divide-y-border">
        <%= for user <- @users do %>
          <div class="px-4 py-3 flex items-center gap-3 hover:bg-y-hover transition-colors duration-100">
            <.link navigate={~p"/#{user.username}"} class="flex flex-1 items-center gap-3 min-w-0 group">
              <YWeb.Layouts.bitmoji user={user} size="sm" />
              <div class="flex-1 min-w-0">
                <p class="text-y-text font-medium text-sm truncate group-hover:underline"><%= user.username %></p>
                <p class="text-y-muted text-xs truncate"><%= user.handle %></p>
              </div>
            </.link>
            <button class="border border-y-white text-y-white rounded-full px-3 py-1 text-xs font-semibold hover:bg-white/10 transition-colors">
              Follow
            </button>
          </div>
        <% end %>
      </div>
      <div class="px-4 py-3 text-y-opinion text-sm font-medium hover:underline cursor-pointer">
        Show more
      </div>
    </div>
    """
  end

  defp trending_widget(assigns) do
    assigns = assign(assigns, :hashtags, Enum.take(YWeb.DummyData.trending_hashtags(), 5))

    ~H"""
    <div class="bg-y-surface rounded-2xl overflow-hidden">
      <div class="px-4 py-3 border-b border-y-border">
        <h3 class="text-y-text font-semibold text-[15px]">Trending</h3>
      </div>
      <div class="divide-y divide-y-border">
        <%= for tag <- @hashtags do %>
          <div class="px-4 py-3 hover:bg-y-hover transition-colors duration-100 group cursor-pointer">
            <p class="text-y-text font-semibold text-sm hover:underline"><%= tag.name %></p>
            <p class="text-y-muted text-xs truncate"><%= Float.round(tag.count / 1000, 1) %>K Takes</p>
          </div>
        <% end %>
      </div>
      <div class="px-4 py-3 text-y-opinion text-sm font-medium hover:underline cursor-pointer">
        Show more
      </div>
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
      class={["shrink-0 rounded-full flex items-center justify-center font-bold text-[#E5E5E7] shadow-inner overflow-hidden", @size_class]}
      style={"background-color: #{@user.bitmoji_color};"}
    >
      <% profile_pic = Map.get(@user, :profile_picture_base64) %>
      <%= if profile_pic && profile_pic != "" do %>
        <img src={profile_pic} class="size-full object-cover" alt={@user.username} />
      <% else %>
        <%= YWeb.Helpers.Bitmoji.initials(@user.username) %>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a single take card.
  """
  attr :take, :map, required: true

  def take_card(assigns) do
    ~H"""
    <.link navigate={~p"/takes/#{@take.id}"} class="block">
      <div class="px-4 py-4 hover:bg-y-hover transition-colors duration-100 cursor-pointer group">
        <div class="flex gap-3">
          <.bitmoji user={@take.user} size="md" />

          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-1.5 mb-0.5">
              <span class="text-y-text font-medium text-sm hover:underline"><%= @take.user.username %></span>
              <span class="text-y-muted text-sm"><%= @take.user.handle %></span>
              <span class="text-y-muted text-sm">· <%= @take.inserted_at %></span>
            </div>

            <%= if @take.type == :opinion do %>
              <p class="text-y-opinion text-sm mb-1">
                Replying to <span class="hover:underline cursor-pointer"><%= @take.parent.user.handle %></span>
              </p>
            <% end %>

            <p class="text-y-text text-[15px] leading-relaxed break-words mt-1">
              <%= @take.body %>
            </p>

            <%= if @take.type in [:retake, :opinion] && @take[:parent] do %>
              <div class="mt-3 border border-y-border rounded-2xl p-3 bg-y-surface hover:bg-y-hover transition-colors">
                <div class="flex items-center gap-2 mb-1">
                  <.bitmoji user={@take.parent.user} size="sm" />
                  <span class="text-y-text font-medium text-sm"><%= @take.parent.user.username %></span>
                  <span class="text-y-muted text-sm"><%= @take.parent.user.handle %></span>
                </div>
                <p class="text-y-text text-sm leading-relaxed truncate">
                  <%= @take.parent.body %>
                </p>
              </div>
            <% end %>

            <div class="flex items-center justify-between mt-4 max-w-sm">
              <.action_button
                icon="hero-chat-bubble-left"
                count={@take.opinion_count}
                hover_text="group-hover/btn:text-y-opinion"
                hover_bg="group-hover/btn:bg-y-opinion/10"
              />
              <.action_button
                icon="hero-arrow-path"
                count={@take.retake_count}
                hover_text="group-hover/btn:text-y-retake"
                hover_bg="group-hover/btn:bg-y-retake/10"
              />
              <.action_button
                icon="hero-heart"
                count={@take.agree_count}
                hover_text="group-hover/btn:text-y-agree"
                hover_bg="group-hover/btn:bg-y-agree/10"
              />
              <.action_button
                icon="hero-bookmark"
                hover_text="group-hover/btn:text-y-bookmark"
                hover_bg="group-hover/btn:bg-y-bookmark/10"
              />
            </div>
          </div>
        </div>
      </div>
    </.link>
    """
  end

  attr :icon, :string, required: true
  attr :count, :integer, default: nil
  attr :hover_text, :string, default: ""
  attr :hover_bg, :string, default: ""

  defp action_button(assigns) do
    ~H"""
    <div class={["flex items-center gap-1 group/btn transition-colors text-y-faint", @hover_text]}>
      <div class={["p-2 rounded-full transition-colors", @hover_bg]}>
        <span class={[@icon, "size-5"]}></span>
      </div>
      <%= if @count do %>
        <span class="text-xs font-medium pr-1"><%= @count %></span>
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
      "info" -> {"hero-information-circle", "text-y-opinion"}
      "error" -> {"hero-x-circle", "text-y-agree"}
      _ -> {"hero-bell", "text-y-white"}
    end

    assigns =
      assigns
      |> assign(:icon, icon)
      |> assign(:color, color)
      |> assign(:message, message)

    ~H"""
    <div
      phx-mounted={show("#toast")}
      class="pointer-events-auto bg-y-border rounded-2xl px-4 py-3 shadow-2xl flex items-center gap-3 animate-in fade-in slide-in-from-right-10 duration-300"
    >
      <span class={[@icon, @color, "size-5"]}></span>
      <span class="text-y-text text-sm font-medium"><%= @message %></span>
      <button class="ml-2 text-y-muted hover:text-white transition-colors">
        <span class="hero-x-mark size-4"></span>
      </button>
    </div>
    """
  end
end
