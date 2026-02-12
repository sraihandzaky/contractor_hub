defmodule ContractorHubWeb.ContractController do
  use ContractorHubWeb, :controller

  alias ContractorHub.Contracts

  action_fallback ContractorHubWeb.FallbackController

  def create(conn, %{"contract" => contract_params}) do
    context = build_context(conn)

    with {:ok, contract} <- Contracts.create_contract(contract_params, context) do
      conn
      |> put_status(:created)
      |> render(:show, contract: contract)
    end
  end

  def index(conn, params) do
    page = Contracts.list_contracts(conn.assigns.current_company_id, params)
    render(conn, :index, page: page)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, contract} <- Contracts.get_contract(conn.assigns.current_company_id, id) do
      render(conn, :show, contract: contract)
    end
  end

  def update(conn, %{"id" => id, "contract" => contract_params}) do
    context = build_context(conn)

    with {:ok, contract} <-
           Contracts.update_contract(conn.assigns.current_company_id, id, contract_params, context) do
      render(conn, :show, contract: contract)
    end
  end

  def activate(conn, %{"id" => id}) do
    context = build_context(conn)

    with {:ok, contract} <-
           Contracts.activate_contract(conn.assigns.current_company_id, id, context) do
      render(conn, :show, contract: contract)
    end
  end

  def complete(conn, %{"id" => id}) do
    context = build_context(conn)

    with {:ok, contract} <-
           Contracts.complete_contract(conn.assigns.current_company_id, id, context) do
      render(conn, :show, contract: contract)
    end
  end

  def terminate(conn, %{"id" => id}) do
    context = build_context(conn)

    with {:ok, contract} <-
           Contracts.terminate_contract(conn.assigns.current_company_id, id, context) do
      render(conn, :show, contract: contract)
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
