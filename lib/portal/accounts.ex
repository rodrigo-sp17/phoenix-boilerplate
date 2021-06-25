defmodule Portal.Accounts do
  @moduledoc """
  The Accounts context.
  """

  require Logger
  import Ecto.Query, warn: false
  alias Portal.Repo

  alias Portal.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> put_pass_hash()
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> put_pass_hash()
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Authenticates a user by its username/email and password
  """
  @spec authenticate_by_password(String.t(), String.t()) ::
          {:error, :unauthorized}
          | {:ok, %Portal.Accounts.User{}}
  def authenticate_by_password(credential, password) do
    query =
      from(u in User,
        where: u.username == ^credential or u.email == ^credential
      )

    case Repo.one(query) do
      %User{} = user ->
        if Argon2.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end

      nil ->
        {:error, :unauthorized}
    end
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    hash = Argon2.hash_pwd_salt(password)
    Ecto.Changeset.change(changeset, password: hash)
  end

  defp put_pass_hash(changeset), do: changeset
end
