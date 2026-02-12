defmodule ContractorHubWeb.ContractorController do
  use ContractorHubWeb, :controller

  alias ContractorHub.Contractors

  action_fallback ContractorHubWeb.FallbackController

  def create(conn, %{"contractor" => contractor_params}) do
    context = build_context(conn)

    with {:ok, contractor} <- Contractors.onboard_contractor(contractor_params, context) do
      conn
      |> put_status(:created)
      |> render(:show, contractor: contractor)
    end
  end

  def index(conn, params) do
    page = Contractors.list_contractors(conn.assigns.current_company_id, params)
    render(conn, :index, page: page)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, contractor} <- Contractors.get_contractor(conn.assigns.current_company_id, id) do
      render(conn, :show, contractor: contractor)
    end
  end

  def update(conn, %{"id" => id, "contractor" => contractor_params}) do
    context = build_context(conn)

    with {:ok, contractor} <-
           Contractors.update_contractor(conn.assigns.current_company_id, id, contractor_params, context) do
      render(conn, :show, contractor: contractor)
    end
  end

  def activate(conn, %{"id" => id}) do
    context = build_context(conn)

    with {:ok, contractor} <-
           Contractors.activate_contractor(conn.assigns.current_company_id, id, context) do
      render(conn, :show, contractor: contractor)
    end
  end

  def offboard(conn, %{"id" => id}) do
    context = build_context(conn)

    with {:ok, contractor} <-
           Contractors.offboard_contractor(conn.assigns.current_company_id, id, context) do
      render(conn, :show, contractor: contractor)
    end
  end

  defp build_context(conn) do
    %{
      company_id: conn.assigns.current_company_id,
      api_key_id: conn.assigns.api_key.id,
      metadata: %{
        ip: to_string(:inet.ntoa(conn.remote_ip)),
        user_agent: get_req_header(conn, "user-agent") |> List.first()
      }
    }
  end
end
