defmodule ContractorHubWeb.FallbackController do
  @moduledoc """
  Translates context return values into HTTP responses.\n
  Used as `action_fallback` in controllers, any `{:error, ...}` returned
  from a controller action is handled here automatically.
  """
  use ContractorHubWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ContractorHubWeb.ErrorJSON)
    |> render("problem.json",
      type: "not_found",
      title: "Not Found",
      status: 404,
      detail: "The requested resource was not found"
    )
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ContractorHubWeb.ErrorJSON)
    |> render("problem.json",
      type: "unauthorized",
      title: "Unauthorized",
      status: 401,
      detail: "Invalid or missing API key"
    )
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ContractorHubWeb.ErrorJSON)
    |> render("validation_error.json", changeset: changeset)
  end

  def call(conn, {:error, :conflict, message}) do
    conn
    |> put_status(:conflict)
    |> put_view(ContractorHubWeb.ErrorJSON)
    |> render("problem.json",
      type: "conflict",
      title: "Conflict",
      status: 409,
      detail: message
    )
  end
end
