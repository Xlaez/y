defmodule YCore.Social.Follow do
  defstruct [:id, :follower_id, :followee_id, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          follower_id: String.t(),
          followee_id: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Social.Block do
  defstruct [:id, :blocker_id, :blocked_id, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          blocker_id: String.t(),
          blocked_id: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Social.Mute do
  defstruct [:id, :muter_id, :muted_id, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          muter_id: String.t(),
          muted_id: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Social.FollowRepository do
  alias YCore.Social.Follow

  @callback follow(follower_id :: String.t(), followee_id :: String.t()) ::
              {:ok, Follow.t()} | {:error, :already_following} | {:error, term()}
  @callback unfollow(follower_id :: String.t(), followee_id :: String.t()) ::
              :ok | {:error, :not_following}
  @callback following?(follower_id :: String.t(), followee_id :: String.t()) :: boolean()
  @callback follower_count(user_id :: String.t()) :: non_neg_integer()
  @callback following_count(user_id :: String.t()) :: non_neg_integer()
  @callback list_followers(user_id :: String.t()) :: [String.t()]
  @callback list_following(user_id :: String.t()) :: [String.t()]
  @callback suggestions(
              user_id :: String.t(),
              blocked_ids :: [String.t()],
              opts :: keyword()
            ) :: [%{user_id: String.t(), mutual_count: non_neg_integer()}]
  @callback invalidate_recommendations(user_id :: String.t()) :: :ok
end

defmodule YCore.Social.BlockRepository do
  alias YCore.Social.Block

  @callback block(blocker_id :: String.t(), blocked_id :: String.t()) ::
              {:ok, Block.t()} | {:error, :already_blocked} | {:error, term()}
  @callback unblock(blocker_id :: String.t(), blocked_id :: String.t()) ::
              :ok | {:error, :not_blocked}
  @callback blocked?(blocker_id :: String.t(), blocked_id :: String.t()) :: boolean()
  @callback list_blocked(user_id :: String.t()) :: [YCore.Accounts.User.t()]
  @callback list_blocked_ids(user_id :: String.t()) :: [String.t()]
  @callback list_blocked_by_ids(user_id :: String.t()) :: [String.t()]
end

defmodule YCore.Social.MuteRepository do
  alias YCore.Social.Mute

  @callback mute(muter_id :: String.t(), muted_id :: String.t()) ::
              {:ok, Mute.t()} | {:error, :already_muted} | {:error, term()}
  @callback unmute(muter_id :: String.t(), muted_id :: String.t()) ::
              :ok | {:error, :not_muted}
  @callback muted?(muter_id :: String.t(), muted_id :: String.t()) :: boolean()
  @callback list_muted(user_id :: String.t()) :: [YCore.Accounts.User.t()]
end
