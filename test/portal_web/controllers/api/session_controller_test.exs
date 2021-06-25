defmodule PortalWeb.API.SessionControllerTest do
  use PortalWeb.ConnCase

  alias Portal.Accounts
  alias Portal.Accounts.User

  @create_attrs %{
    email: "some@mail.com",
    name: "some name",
    username: "some username",
    password: "some password"
  }
  @valid_email_attrs %{
    username: "some@mail.com",
    password: "some password"
  }
  @valid_username_attrs %{
    username: "some username",
    password: "some password"
  }

  @invalid_credential_attrs %{username: "", password: "some password"}
  @invalid_password_attrs %{username: "some@mail.com", password: "wrong"}

  def fixture() do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end

  describe "login" do
    setup [:create_user]

    test "login email", %{conn: conn} do
      conn = post(conn, Routes.api_session_path(conn, :create), @valid_email_attrs)
      assert response(conn, 200)
    end

    test "login username", %{conn: conn} do
      conn = post(conn, Routes.api_session_path(conn, :create), @valid_username_attrs)
      assert response(conn, 200)
    end

    test "login invalid credential", %{conn: conn} do
      conn = post(conn, Routes.api_session_path(conn, :create), @invalid_credential_attrs)
      assert json_response(conn, 401)
    end

    test "login invalid password", %{conn: conn} do
      conn = post(conn, Routes.api_session_path(conn, :create), @invalid_password_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "logout" do
    setup [:create_user]

    test "logout", %{conn: conn} do
      conn = post(conn, Routes.api_session_path(conn, :create), @valid_email_attrs)
      assert response(conn, 200)

      conn = delete(conn, Routes.api_session_path(conn, :delete))
      assert response(conn, 200)
    end
  end

  defp create_user(_) do
    user = fixture()
    %{user: user}
  end
end
