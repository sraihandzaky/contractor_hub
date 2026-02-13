defmodule ContractorHubWeb.ContractController do
  @moduledoc "Handles contract CRUD operations and lifecycle transitions."
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHub.Contracts

  alias ContractorHubWeb.Schemas.{
    ContractListResponse,
    ContractRequest,
    ContractResponse,
    ContractUpdateRequest,
    ProblemDetail,
    ValidationError
  }

  action_fallback ContractorHubWeb.FallbackController

  tags(["Contracts"])

  operation(:create,
    summary: "Create a contract",
    description: "Creates a new contract for a contractor in draft status",
    request_body: {"Contract params", "application/json", ContractRequest},
    responses: [
      created: {"Created contract", "application/json", ContractResponse},
      not_found: {"Contractor not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:index,
    summary: "List contracts",
    description: "Returns a paginated list of contracts for the authenticated company",
    parameters: [
      status: [
        in: :query,
        type: :string,
        description: "Filter by status (draft, active, completed, terminated)"
      ],
      rate_type: [
        in: :query,
        type: :string,
        description: "Filter by rate type (hourly, daily, weekly, monthly, fixed)"
      ],
      contractor_id: [in: :query, type: :string, description: "Filter by contractor ID"],
      sort: [in: :query, type: :string, description: "Sort field (e.g. inserted_at, title)"],
      limit: [in: :query, type: :integer, description: "Number of results per page"],
      after: [in: :query, type: :string, description: "Cursor for next page"],
      before: [in: :query, type: :string, description: "Cursor for previous page"]
    ],
    responses: [
      ok: {"Paginated contracts", "application/json", ContractListResponse}
    ]
  )

  operation(:show,
    summary: "Get a contract",
    description: "Returns a single contract by ID",
    parameters: [
      id: [in: :path, type: :string, description: "Contract ID", required: true]
    ],
    responses: [
      ok: {"Contract details", "application/json", ContractResponse},
      not_found: {"Not found", "application/json", ProblemDetail}
    ]
  )

  operation(:update,
    summary: "Update a contract",
    description: "Updates an existing contract's details",
    parameters: [
      id: [in: :path, type: :string, description: "Contract ID", required: true]
    ],
    request_body: {"Contract update params", "application/json", ContractUpdateRequest},
    responses: [
      ok: {"Updated contract", "application/json", ContractResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:activate,
    summary: "Activate a contract",
    description: "Transitions a contract from draft to active status",
    parameters: [
      id: [in: :path, type: :string, description: "Contract ID", required: true]
    ],
    responses: [
      ok: {"Activated contract", "application/json", ContractResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:complete,
    summary: "Complete a contract",
    description: "Transitions an active contract to completed status",
    parameters: [
      id: [in: :path, type: :string, description: "Contract ID", required: true]
    ],
    responses: [
      ok: {"Completed contract", "application/json", ContractResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:terminate,
    summary: "Terminate a contract",
    description: "Terminates an active contract",
    parameters: [
      id: [in: :path, type: :string, description: "Contract ID", required: true]
    ],
    responses: [
      ok: {"Terminated contract", "application/json", ContractResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

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
           Contracts.update_contract(
             conn.assigns.current_company_id,
             id,
             contract_params,
             context
           ) do
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
