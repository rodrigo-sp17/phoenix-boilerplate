defmodule HelloWeb.Plugs.Locale do
  @moduledoc """
  Plug to extract locale or set a default one
  """

  import Plug.Conn

  @locales ["en", "pt-BR"]

  @spec init(String.t()) :: String.t()
  def init(default), do: default

  @spec call(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _) when loc in @locales do
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    assign(conn, :locale, default)
  end
end
