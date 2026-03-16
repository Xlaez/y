defmodule Mix.Tasks.Y.Seed do
  use Mix.Task
  alias YRepo.Repo
  alias YRepo.Schemas.User
  alias YRepo.Repositories.{UserRepository, TakeRepository, FollowRepository, AgreeRepository, BookmarkRepository, OpinionRepository, RetakeRepository}
  alias YCore.Content.{TakeService, RetakeService, OpinionService}

  @shortdoc "Seeds the database with rich content data"

  def run(_args) do
    Mix.Task.run("app.start")

    # 0. Cleanup with TRUNCATE for a true fresh start
    Repo.query!("TRUNCATE TABLE users, takes, retakes, opinions, follows, agrees, bookmarks CASCADE")

    IO.puts "🌱 Seeding 10 users..."
    users = create_users(10)

    IO.puts "📝 Generating 300+ takes..."
    takes = generate_takes(users, 350)

    IO.puts "🤝 Creating follow relationships..."
    create_follows(users)

    IO.puts "🔄 Generating retakes and opinions..."
    generate_interactions(users, takes)

    IO.puts "✅ Seeding complete!"
  end

  defp create_users(count) do
    for i <- 1..count do
      username = "user_#{i}"
      {:ok, %{user: user}} = YCore.Accounts.RegistrationService.register(%{
        username: username,
        password: "password123"
      }, UserRepository)
      user
    end
  end

  defp generate_takes(users, count) do
    bodies = [
      "The best way to predict the future is to invent it.",
      "Simplicity is the ultimate sophistication.",
      "Stay hungry, stay foolish.",
      "Move fast and break things.",
      "The only way to do great work is to love what you do.",
      "Innovation distinguishes between a leader and a follower.",
      "Your time is limited, so don't waste it living someone else's life.",
      "Design is not just what it looks like and feels like. Design is how it works.",
      "Be a yardstick of quality. Some people aren't used to an environment where excellence is expected.",
      "I want to put a ding in the universe."
    ]

    for _ <- 1..count do
      user = Enum.random(users)
      body = Enum.random(bodies) <> " ##{Enum.random(1..1000)}"
      {:ok, take} = TakeService.post(user.id, body, TakeRepository)
      take
    end
  end

  defp create_follows(users) do
    for u1 <- users, u2 <- users, u1.id != u2.id do
      if :rand.uniform() > 0.4 do
        YCore.Social.FollowService.follow(u1.id, u2.id, FollowRepository)
      end
    end
  end

  defp generate_interactions(users, takes) do
    for take <- takes do
      # Agrees
      for user <- Enum.take_random(users, Enum.random(0..length(users))) do
        AgreeRepository.toggle(user.id, :take, take.id)
      end

      # Retakes
      retakers = Enum.take_random(users, Enum.random(0..3))
      for user <- retakers, user.id != take.user_id do
        comment = if :rand.uniform() > 0.5, do: "Check this out!", else: nil
        RetakeService.retake(user.id, take.id, comment, RetakeRepository, TakeRepository)
      end

      # Opinions (Threaded)
      num_opinions = Enum.random(0..5)
      for _ <- 0..num_opinions do
        user = Enum.random(users)
        {:ok, op} = OpinionService.post(%{user_id: user.id, take_id: take.id, body: "Interesting perspective!"}, OpinionRepository, TakeRepository)

        # Nested opinions
        if :rand.uniform() > 0.7 do
          user2 = Enum.random(users)
          OpinionService.post(%{user_id: user2.id, take_id: take.id, parent_opinion_id: op.id, body: "I agree with this opinion."}, OpinionRepository, TakeRepository)
        end
      end
    end
  end
end
