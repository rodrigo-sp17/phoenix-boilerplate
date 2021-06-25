defmodule PortalWeb.Router do
  use PortalWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HelloWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug HelloWeb.Plugs.Locale, "en"
  end

  ## Serves the SPA app
  scope "/", PortalWeb do
    pipe_through :browser
  end

  # Authenticated API routes
  scope "/api", PortalWeb.API, as: :api do
    pipe_through [:api, :authenticate_user]

    resources "/users", UserController, except: [:new, :index, :edit, :create]
    delete "/sessions", SessionController, :delete
  end

  # Unauthenticated API routes
  scope "/api", PortalWeb.API, as: :api do
    pipe_through [:api]

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PortalWeb.Telemetry
    end
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> PortalWeb.FallbackController.call({:error, :forbidden})
        |> halt()

      user_id ->
        # TODO - introduce Redis session management
        assign(conn, :user_id, user_id)
    end
  end
end
