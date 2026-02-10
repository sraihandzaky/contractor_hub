defmodule ContractorHubWeb.ErrorJSON do
  @moduledoc "Renders errors in RFC 7807 Problem Details format."

  def render("problem.json", assigns) do
    %{
      type: assigns.type,
      title: assigns.title,
      status: assigns.status,
      detail: assigns.detail
    }
  end

  def render("validation_error.json", %{changeset: changeset}) do
    %{
      type: "validation_error",
      title: "Unprocessable Entity",
      status: 422,
      detail: "Request validation failed",
      errors: format_errors(changeset)
    }
  end

  # Fallback for Phoenix's default error pages (500, etc.)
  def render(template, _assigns) do
    %{
      type: "server_error",
      title: Phoenix.Controller.status_message_from_template(template),
      status: 500,
      detail: "An internal server error occurred"
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
