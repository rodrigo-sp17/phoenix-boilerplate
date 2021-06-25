defmodule PortalWeb.API.UserControllerTest do
  use PortalWeb.ConnCase

  alias Portal.Accounts
  alias Portal.Accounts.User

  @create_attrs %{
    user: %{
      email: "some@email.com",
      name: "some name",
      username: "some username",
      password: "some password"
    },
    confirm_password: "some password"
  }
  @invalid_creation_attrs %{
    user: %{
      email: "some email.com",
      name: "some name",
      username: "some username",
      password: "some password"
    },
    confirm_password: "some password"
  }
  @invalid_password_attrs %{
    user: %{
      email: "another@email.com",
      name: "some name",
      username: "another username",
      password: "some password"
    },
    confirm_password: "non matching"
  }
  @update_attrs %{
    email: "updated@email.com",
    name: "some updated name",
    username: "some updated username"
  }
  @invalid_attrs %{
    email: "some email.com",
    name: "some updated name",
    username: "some updated username",
    password: "new password"
  }

  def fixture(:user) do
    {:ok, newUser} = Accounts.create_user(@create_attrs.user)
    newUser
  end

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), @create_attrs)

      assert %{
               "id" => id,
               "email" => "some@email.com",
               "name" => "some name",
               "username" => "some username"
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when passwords dont' match", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), @invalid_password_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), @invalid_creation_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user, :login_as_registered_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.api_user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "updated@email.com",
               "name" => "some updated name",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.api_user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user, :login_as_registered_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.api_user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    newUser = fixture(:user)
    %{user: newUser}
  end

  defp login_as_registered_user(%{conn: conn, user: user}) do
    conn = Plug.Test.init_test_session(conn, %{:user_id => user.id})
    {:ok, conn: conn}
  end
end
