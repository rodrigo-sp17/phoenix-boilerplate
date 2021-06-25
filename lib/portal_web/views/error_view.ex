defmodule PortalWeb.ErrorView do
  use PortalWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("error.json", %{error: :unauthorized}) do
    msg = translate_error({"Invalid username or password", []})
    build_error_json("Unauthorized", msg, "")
  end

  def render("error.json", %{error: :forbidden}) do
    msg = translate_error({"Access denied", []})
    build_error_json("Forbidden", msg, "")
  end

  def render("error.json", %{error: :bad_request, message: message}) do
    msg = translate_error({message, []})
    build_error_json("Invalid data", msg, "")
  end

  @spec build_error_json(String.t(), String.t(), String.t()) :: Map.t()
  defp build_error_json(error, message, detail) do
    %{
      error: error,
      message: message,
      detail: detail
    }
  end
end
