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
  @callback create(params :: map()) :: {:ok, YCore.Social.Follow.t()} | {:error, any()}
  @callback delete(follow :: YCore.Social.Follow.t()) :: :ok | {:error, any()}
end

defmodule YCore.Social.BlockRepository do
  @callback create(params :: map()) :: {:ok, YCore.Social.Block.t()} | {:error, any()}
  @callback delete(block :: YCore.Social.Block.t()) :: :ok | {:error, any()}
end

defmodule YCore.Social.MuteRepository do
  @callback create(params :: map()) :: {:ok, YCore.Social.Mute.t()} | {:error, any()}
  @callback delete(mute :: YCore.Social.Mute.t()) :: :ok | {:error, any()}
end
