defmodule ContractorHubWeb.CompanyController do
  @moduledoc "Handles company registration, retrieval, and updates."
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHub.Companies

  alias ContractorHubWeb.Schemas.{
    CompanyRequest,
    CompanyResponse,
    CompanyUpdateRequest,
    CompanyWithKeyResponse,
    ProblemDetail,
    ValidationError
  }

  action_fallback ContractorHubWeb.FallbackController

  tags(["Companies"])

  operation(:create,
    summary: "Register a new company",
    description: "Creates a company account and returns an API key for authentication",
    security: [],
    request_body: {"Company registration params", "application/json", CompanyRequest},
    responses: [
      created: {"Company with API key", "application/json", CompanyWithKeyResponse},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:show,
    summary: "Get current company",
    description: "Returns the authenticated company's details",
    responses: [
      ok: {"Company details", "application/json", CompanyResponse},
      unauthorized: {"Unauthorized", "application/json", ProblemDetail}
    ]
  )

  operation(:update,
    summary: "Update current company",
    description: "Updates the authenticated company's details",
    request_body: {"Company update params", "application/json", CompanyUpdateRequest},
    responses: [
      ok: {"Updated company", "application/json", CompanyResponse},
      unauthorized: {"Unauthorized", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  # POST /api/v1/companies — public, returns API key
  @spec create(any(), map()) :: {:error, any()} | Plug.Conn.t()
  def create(conn, %{"company" => company_params}) do
    case Companies.register_company(company_params) do
      {:ok, company, raw_api_key} ->
        conn
        |> put_status(:created)
        |> render(:show_with_key, company: company, api_key: raw_api_key)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # GET /api/v1/companies/me — authenticated
  def show(conn, _params) do
    company = Companies.get_active_company(conn.assigns.current_company_id)
    render(conn, :show, company: company)
  end

  # PATCH /api/v1/companies/me — authenticated
  def update(conn, %{"company" => company_params}) do
    company = Companies.get_active_company(conn.assigns.current_company_id)

    with {:ok, company} <- Companies.update_company(company, company_params) do
      render(conn, :show, company: company)
    end
  end
end
