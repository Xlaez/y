defmodule YCore.Accounts.User do
  @moduledoc """
  Core domain entity representing a User.
  All fields are required for a valid user instance.
  """

  @enforce_keys [
    :id, :username, :password_hash, :seed_phrase_hash, 
    :bitmoji_id, :bitmoji_color, :handle, 
    :follower_count, :following_count, :take_count, 
    :is_locked
  ]
  defstruct [
    :id,
    :username,
    :password_hash,
    :seed_phrase_hash,
    :bitmoji_id,
    :bitmoji_color,
    :display_name,
    :profile_picture_base64,
    :handle,
    :follower_count,
    :following_count,
    :take_count,
    :is_locked,
    :inserted_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          username: String.t(),
          password_hash: String.t(),
          seed_phrase_hash: String.t(),
          bitmoji_id: String.t(),
          bitmoji_color: String.t(),
          display_name: String.t() | nil,
          profile_picture_base64: String.t() | nil,
          handle: String.t(),
          is_locked: boolean(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
