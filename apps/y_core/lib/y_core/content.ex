defmodule YCore.Content.TakeBody do
  defstruct [:value]
  @type t :: %__MODULE__{value: String.t()}

  def new(value) when is_binary(value) do
    trimmed = String.trim(value)
    if valid?(trimmed) do
      {:ok, %__MODULE__{value: trimmed}}
    else
      {:error, :invalid_take_body}
    end
  end

  defp valid?(value) do
    len = String.length(value)
    len > 0 and len <= 250
  end
end

defmodule YCore.Content.Take do
  defstruct [:id, :user_id, :body, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          body: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Content.Retake do
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
  defstruct [:id, :user_id, :parent_take_id, :parent_opinion_id, :body, :inserted_at]
  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          parent_take_id: String.t() | nil,
          parent_opinion_id: String.t() | nil,
          body: String.t(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Content.TakeRepository do
  @callback get_by_id(id :: String.t()) :: {:ok, YCore.Content.Take.t()} | {:error, :not_found}
  @callback get_with_user(id :: String.t()) :: {:ok, map()} | {:error, :not_found}
  @callback create(params :: map()) :: {:ok, YCore.Content.Take.t()} | {:error, any()}
  @callback delete(take :: YCore.Content.Take.t()) :: :ok | {:error, any()}
end

defmodule YCore.Content.RetakeRepository do
  @callback create(params :: map()) :: {:ok, YCore.Content.Retake.t()} | {:error, any()}
end

defmodule YCore.Content.OpinionRepository do
  @callback list_by_take(take_id :: String.t()) :: [map()]
  @callback list_by_opinion(opinion_id :: String.t()) :: [map()]
  @callback create(params :: map()) :: {:ok, YCore.Content.Opinion.t()} | {:error, any()}
end
