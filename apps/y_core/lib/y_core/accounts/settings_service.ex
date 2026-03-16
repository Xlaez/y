defmodule YCore.Accounts.SettingsService do
  alias YCore.Accounts.ValueObjects.Password

  @permitted_colors [
    "#6B2D2D", "#8B3A3A", "#A0522D", "#8B4513", "#556B2F",
    "#2E4A2E", "#2F4F4F", "#1C3A4A", "#2E3B55", "#3A3A6B",
    "#4A2E5C", "#5C2E5C", "#6B2D5B", "#3A3A3C", "#5A5A5A",
    "#1A1A2E"
  ]

  @spec change_password(String.t(), String.t(), String.t(), module()) ::
          {:ok, term()} | {:error, :invalid_current_password} | {:error, String.t()} | {:error, term()}
  def change_password(user_id, current_password, new_password, user_repo) do
    case user_repo.get_by_id(user_id) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, user} ->
        if Bcrypt.verify_pass(current_password, user.password_hash) do
          case Password.validate(new_password) do
            :ok ->
              new_hash = Bcrypt.hash_pwd_salt(new_password)
              user_repo.update(user, %{password_hash: new_hash})

            {:error, reason} ->
              {:error, reason}
          end
        else
          {:error, :invalid_current_password}
        end
    end
  end

  @spec change_bitmoji(String.t(), String.t(), module()) ::
          {:ok, term()} | {:error, :invalid_color} | {:error, term()}
  def change_bitmoji(user_id, color, user_repo) do
    if color in @permitted_colors do
      case user_repo.get_by_id(user_id) do
        {:error, :not_found} -> {:error, :not_found}
        {:ok, user} -> user_repo.update(user, %{bitmoji_color: color})
      end
    else
      {:error, :invalid_color}
    end
  end

  @spec toggle_lock(String.t(), module()) :: {:ok, term()} | {:error, term()}
  def toggle_lock(user_id, user_repo) do
    case user_repo.get_by_id(user_id) do
      {:error, :not_found} -> {:error, :not_found}
      {:ok, user} -> user_repo.update(user, %{is_locked: !user.is_locked})
    end
  end

  @spec delete_account(String.t(), String.t(), module(), module()) ::
          :ok | {:error, :invalid_password} | {:error, term()}
  def delete_account(user_id, password_confirmation, user_repo, session_repo) do
    case user_repo.get_by_id(user_id) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, user} ->
        if Bcrypt.verify_pass(password_confirmation, user.password_hash) do
          session_repo.delete_all_for_user(user_id)
          user_repo.delete(user_id)
        else
          {:error, :invalid_password}
        end
    end
  end

  def permitted_colors, do: @permitted_colors
end
