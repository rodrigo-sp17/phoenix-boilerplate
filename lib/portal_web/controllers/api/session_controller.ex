defmodule PortalWeb.API.SessionController do
  use PortalWeb, :controller

  alias Portal.Accounts

  action_fallback PortalWeb.FallbackController

  def create(conn, %{"username" => username, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_by_password(username, password) do
      conn
      |> put_session(:user_id, user.id)
      |> configure_session(renew: true)
      |> send_resp(:ok, "")
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:ok, "")
  end

  defp store_in_cache do
    # TODO
  end

  defp remove_from_cache do
    # TODO
  end
end
