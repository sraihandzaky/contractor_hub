defmodule ContractorHubWeb.CompanyController do
  use ContractorHubWeb, :controller

  alias ContractorHub.Companies

  action_fallback ContractorHubWeb.FallbackController

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
