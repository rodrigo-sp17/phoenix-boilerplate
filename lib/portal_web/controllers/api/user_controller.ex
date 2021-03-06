defmodule PortalWeb.API.UserController do
  use PortalWeb, :controller

  alias Portal.Accounts
  alias Portal.Accounts.User

  action_fallback PortalWeb.FallbackController

  plug :authorize_user when action in [:show, :update, :delete]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{
        "user" => user_params,
        "confirm_password" => password_confirmation
      }) do
    password = Map.get(user_params, "password")

    with {:ok} <- confirm_password(password, password_confirmation),
         {:ok, %User{} = user} <-
           Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp confirm_password(password, password_confirmation) do
    if password === password_confirmation do
      {:ok}
    else
      {:error, :bad_request, "Password and confirmation do not match"}
    end
  end

  defp authorize_user(conn, _) do
    user = Accounts.get_user!(conn.params["id"])

    if conn.assigns.user_id == user.id do
      assign(conn, :user, user)
    else
      # TODO - evaluate standardized message from plug
      send_resp(conn, :forbidden, "")
    end
  end
end
