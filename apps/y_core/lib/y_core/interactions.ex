defmodule YCore.Interactions.Agree do
  defstruct [:id, :user_id, :target_type, :target_id, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          target_type: :take | :retake | :opinion,
          target_id: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Interactions.Bookmark do
  defstruct [:id, :user_id, :target_type, :target_id, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          target_type: :take | :retake | :opinion,
          target_id: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Interactions.AgreeRepository do
  @callback create(params :: map()) :: {:ok, YCore.Interactions.Agree.t()} | {:error, any()}
  @callback delete(agree :: YCore.Interactions.Agree.t()) :: :ok | {:error, any()}
end

defmodule YCore.Interactions.BookmarkRepository do
  @callback create(params :: map()) :: {:ok, YCore.Interactions.Bookmark.t()} | {:error, any()}
  @callback delete(bookmark :: YCore.Interactions.Bookmark.t()) :: :ok | {:error, any()}
end
