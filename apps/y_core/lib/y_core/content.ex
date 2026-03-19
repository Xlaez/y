defmodule YCore.Content.TakeBody do
  defstruct [:value]
  @type t :: %__MODULE__{value: String.t()}

  @spec new(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def new(value) when is_binary(value) do
    trimmed = String.trim(value)
    len = String.length(trimmed)

    cond do
      len == 0 -> {:error, "Body cannot be empty"}
      len > 250 -> {:error, "Body is too long (max 250 characters)"}
      true -> {:ok, trimmed}
    end
  end
end

defmodule YCore.Content.Take do
  @enforce_keys [:id, :user_id, :body, :inserted_at]
  defstruct [:id, :user_id, :body, :inserted_at, :author, opinion_count: 0, retake_count: 0]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          body: String.t(),
          inserted_at: DateTime.t(),
          opinion_count: non_neg_integer(),
          retake_count: non_neg_integer()
        }
end

defmodule YCore.Content.Retake do
  @enforce_keys [:id, :user_id, :original_take_id, :inserted_at]
  defstruct [:id, :user_id, :original_take_id, :comment, :inserted_at]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          original_take_id: String.t(),
          comment: String.t() | nil,
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Content.Opinion do
  @enforce_keys [:id, :user_id, :take_id, :body, :depth, :inserted_at]
  defstruct [:id, :user_id, :take_id, :parent_opinion_id, :body, :depth, :inserted_at]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          take_id: String.t(),
          parent_opinion_id: String.t() | nil,
          body: String.t(),
          depth: non_neg_integer(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Content.TakeRepository do
  alias YCore.Content.Take

  @callback create(map()) :: {:ok, Take.t()} | {:error, term()}
  @callback get_by_id(String.t()) :: {:ok, Take.t()} | {:error, :not_found}
  @callback delete(String.t(), String.t()) :: :ok | {:error, :not_found | :forbidden}
  @callback list_for_feed(user_ids :: [String.t()], opts :: keyword()) :: [Take.t()]
  @callback list_for_user(user_id :: String.t(), opts :: keyword()) :: [Take.t()]
  @callback count_for_user(user_id :: String.t()) :: non_neg_integer()
  @callback increment_opinion_count(take_id :: String.t()) :: :ok
  @callback increment_retake_count(take_id :: String.t()) :: :ok
  @callback list_by_ids(take_ids :: [String.t()]) :: [Take.t()]
  @callback search(String.t(), keyword()) :: [Take.t()]
end

defmodule YCore.Content.RetakeRepository do
  alias YCore.Content.Retake

  @callback create(map()) :: {:ok, Retake.t()} | {:error, :already_retook | term()}
  @callback get_by_id(String.t()) :: {:ok, Retake.t()} | {:error, :not_found}
  @callback delete(String.t(), String.t()) :: :ok | {:error, :not_found | :forbidden}
  @callback already_retook?(user_id :: String.t(), take_id :: String.t()) :: boolean()
  @callback list_retook_ids(user_id :: String.t(), take_ids :: [String.t()]) :: [String.t()]
  @callback count_for_take(take_id :: String.t()) :: non_neg_integer()
  @callback list_by_ids(retake_ids :: [String.t()]) :: [Retake.t()]
end

defmodule YCore.Content.OpinionRepository do
  alias YCore.Content.Opinion

  @callback create(map()) :: {:ok, Opinion.t()} | {:error, term()}
  @callback get_by_id(String.t()) :: {:ok, Opinion.t()} | {:error, :not_found}
  @callback delete(String.t(), String.t()) :: :ok | {:error, :not_found | :forbidden}
  @callback list_for_take(take_id :: String.t()) :: [Opinion.t()]
  @callback list_for_user(user_id :: String.t(), opts :: keyword()) :: [Opinion.t()]
  @callback count_for_take(take_id :: String.t()) :: non_neg_integer()
  @callback list_by_ids(opinion_ids :: [String.t()]) :: [Opinion.t()]
end
