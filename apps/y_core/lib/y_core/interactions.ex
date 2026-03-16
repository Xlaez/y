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
  @callback toggle(user_id :: String.t(), target_type :: atom(), target_id :: String.t()) ::
              {:ok, :agreed} | {:ok, :removed} | {:error, term()}
  @callback agreed?(user_id :: String.t(), target_type :: atom(), target_id :: String.t()) ::
              boolean()
  @callback count(target_type :: atom(), target_id :: String.t()) :: non_neg_integer()
  @callback list_agreed_ids(user_id :: String.t(), target_type :: atom(), target_ids :: [String.t()]) ::
              [String.t()]
end

defmodule YCore.Interactions.BookmarkRepository do
  @callback toggle(user_id :: String.t(), target_type :: atom(), target_id :: String.t()) ::
              {:ok, :saved} | {:ok, :removed} | {:error, term()}
  @callback bookmarked?(user_id :: String.t(), target_type :: atom(), target_id :: String.t()) ::
              boolean()
  @callback list_for_user(user_id :: String.t(), opts :: keyword()) :: [map()]
end
