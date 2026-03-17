defmodule YWeb.DummyData do
  @moduledoc """
  Provdes dummy data for UI implementation of 'y'.
  """

  def users do
    [
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d471", username: "voidwalker", handle: "@voidwalker", bitmoji_color: "#3A3A3C", is_locked: false, follower_count: 1204, following_count: 840, take_count: 42},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d472", username: "npcenergy", handle: "@npcenergy", bitmoji_color: "#48484A", is_locked: false, follower_count: 231, following_count: 45, take_count: 156},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d473", username: "contrarianhq", handle: "@contrarianhq", bitmoji_color: "#636366", is_locked: true, follower_count: 8900, following_count: 12, take_count: 1205},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d474", username: "hottakes99", handle: "@hottakes99", bitmoji_color: "#2C2C2E", is_locked: false, follower_count: 45, following_count: 200, take_count: 8},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d475", username: "shadowban_survivor", handle: "@survivor", bitmoji_color: "#1C1C1E", is_locked: false, follower_count: 15, following_count: 300, take_count: 12},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d476", username: "elixir_wizard", handle: "@beam_me_up", bitmoji_color: "#3A3A3C", is_locked: false, follower_count: 450, following_count: 450, take_count: 89},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d477", username: "crypto_skeptic", handle: "@fiat_only", bitmoji_color: "#48484A", is_locked: false, follower_count: 120, following_count: 120, take_count: 56},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d478", username: "anon_ops", handle: "@anon", bitmoji_color: "#636366", is_locked: true, follower_count: 0, following_count: 0, take_count: 3},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d479", username: "maincharacter", handle: "@it_is_me", bitmoji_color: "#2C2C2E", is_locked: false, follower_count: 99000, following_count: 1, take_count: 500},
      %{id: "f47ac10b-58cc-4372-a567-0e02b2c3d480", username: "doom_scroller", handle: "@endless", bitmoji_color: "#48484A", is_locked: false, follower_count: 5, following_count: 5000, take_count: 0}
    ]
  end

  def current_user do
    Enum.at(users(), 0)
  end

  def takes do
    all_users = users()
    
    [
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a1",
        user: Enum.at(all_users, 2),
        body: "I actually think PHP is better than Elixir for scaling. There, I said it. Come at me.",
        agree_count: 142,
        retake_count: 38,
        opinion_count: 17,
        inserted_at: "2h",
        type: :take
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a2",
        user: Enum.at(all_users, 1),
        body: "Just saw a guy eating a banana with a fork. Humanity is doomed.",
        agree_count: 89,
        retake_count: 5,
        opinion_count: 12,
        inserted_at: "5h",
        type: :take
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a3",
        user: Enum.at(all_users, 5),
        body: "The BEAM is not just a virtual machine, it's a lifestyle. If you don't dream in processes, you're doing it wrong.",
        agree_count: 450,
        retake_count: 120,
        opinion_count: 45,
        inserted_at: "1h",
        type: :take
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a4",
        user: Enum.at(all_users, 0),
        body: "Wait, so 'y' is just a dark-mode mockery of X? I love it already.",
        agree_count: 10,
        retake_count: 1,
        opinion_count: 0,
        inserted_at: "10m",
        type: :take
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a5",
        user: Enum.at(all_users, 6),
        body: "Crypto is just multi-level marketing for people who are good at math. Change my mind.",
        agree_count: 1500,
        retake_count: 400,
        opinion_count: 90,
        inserted_at: "12h",
        type: :take
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a6",
        user: Enum.at(all_users, 3), # retake
        body: "This is a cold take but someone has to say it.",
        agree_count: 5,
        retake_count: 0,
        opinion_count: 1,
        inserted_at: "3h",
        type: :retake,
        parent: %{
          user: Enum.at(all_users, 2),
          body: "I actually think PHP is better than Elixir for scaling. There, I said it. Come at me."
        }
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a7",
        user: Enum.at(all_users, 4), # opinion/reply
        body: "Hard agree. The banana industry is lobbying for fork usage anyway.",
        agree_count: 12,
        retake_count: 0,
        opinion_count: 0,
        inserted_at: "1h",
        type: :opinion,
        parent: %{
          user: Enum.at(all_users, 1),
          body: "Just saw a guy eating a banana with a fork. Humanity is doomed."
        }
      },
      %{
        id: "f47ac10b-58cc-4372-a567-0e02b2c3d4a8",
        user: Enum.at(all_users, 8),
        body: "I am once again asking for your attention. Look at me.",
        agree_count: 0,
        retake_count: 0,
        opinion_count: 500,
        inserted_at: "30m",
        type: :take
      }
    ]
  end

  def notifications do
    all_users = users()
    [
      %{id: 1, type: :agreed, actor: Enum.at(all_users, 1), text: "agreed with your take", excerpt: "Wait, so 'y' is just a dark-mode...", timestamp: "2m", unread: true},
      %{id: 2, type: :opinion, actor: Enum.at(all_users, 2), text: "replied to your take", excerpt: "Hard agree. The banana industry...", timestamp: "15m", unread: true},
      %{id: 3, type: :followed, actor: Enum.at(all_users, 3), text: "followed you", excerpt: nil, timestamp: "1h", unread: false},
      %{id: 4, type: :retake, actor: Enum.at(all_users, 5), text: "retook your take", excerpt: "The BEAM is not just a...", timestamp: "3h", unread: false},
      %{id: 5, type: :agreed, actor: Enum.at(all_users, 4), text: "agreed with your take", excerpt: "I am once again asking...", timestamp: "5h", unread: false},
      %{id: 6, type: :followed, actor: Enum.at(all_users, 6), text: "followed you", excerpt: nil, timestamp: "12h", unread: false},
      %{id: 7, type: :opinion, actor: Enum.at(all_users, 7), text: "replied to your take", excerpt: "Crypto is just multi-level...", timestamp: "1d", unread: false},
      %{id: 8, type: :retake, actor: Enum.at(all_users, 8), text: "retook your take", excerpt: "I actually think PHP is...", timestamp: "1d", unread: false},
      %{id: 9, type: :agreed, actor: Enum.at(all_users, 9), text: "agreed with your take", excerpt: "Just saw a guy eating...", timestamp: "2d", unread: false},
      %{id: 10, type: :followed, actor: Enum.at(all_users, 1), text: "followed you", excerpt: nil, timestamp: "3d", unread: false}
    ]
  end

  def trending_hashtags do
    [
      %{name: "#unpopularopinion", count: 4200},
      %{name: "#hotnoise", count: 1800},
      %{name: "#beamlang", count: 1200},
      %{name: "#saywhatever", count: 950},
      %{name: "#doomscrolling", count: 840},
      %{name: "#javascript_fatigue", count: 720},
      %{name: "#darkmode_everything", count: 500},
      %{name: "#broken_timeline", count: 312}
    ]
  end

  def muted_users do
    all_users = users()
    [
      Enum.at(all_users, 7),
      Enum.at(all_users, 8)
    ]
  end

  def blocked_users do
    all_users = users()
    [
      Enum.at(all_users, 1),
      Enum.at(all_users, 3),
      Enum.at(all_users, 4),
      Enum.at(all_users, 9)
    ]
  end

  def followers(_user_id) do
    all_users = users()
    # Random-ish subset for demo
    [
      Enum.at(all_users, 1),
      Enum.at(all_users, 2),
      Enum.at(all_users, 5),
      Enum.at(all_users, 6),
      Enum.at(all_users, 7)
    ]
  end

  def following(_user_id) do
    all_users = users()
    # Random-ish subset for demo
    [
      Enum.at(all_users, 2),
      Enum.at(all_users, 3),
      Enum.at(all_users, 4),
      Enum.at(all_users, 8),
      Enum.at(all_users, 9)
    ]
  end
end
