defmodule ContractorHubWeb.ContractorController do
  @moduledoc "Handles contractor CRUD operations and status transitions."
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHub.Contractors

  alias ContractorHubWeb.Schemas.{
    ContractorListResponse,
    ContractorRequest,
    ContractorResponse,
    ContractorUpdateRequest,
    ProblemDetail,
    ValidationError
  }

  action_fallback ContractorHubWeb.FallbackController

  tags(["Contractors"])

  operation(:create,
    summary: "Onboard a contractor",
    description: "Creates a new contractor in draft status",
    request_body: {"Contractor params", "application/json", ContractorRequest},
    responses: [
      created: {"Created contractor", "application/json", ContractorResponse},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:index,
    summary: "List contractors",
    description: "Returns a paginated list of contractors for the authenticated company",
    parameters: [
      country_code: [in: :query, type: :string, description: "Filter by country code"],
      status: [
        in: :query,
        type: :string,
        description: "Filter by status (draft, active, offboarded)"
      ],
      search: [in: :query, type: :string, description: "Search by name or email"],
      sort: [in: :query, type: :string, description: "Sort field (e.g. inserted_at, full_name)"],
      limit: [in: :query, type: :integer, description: "Number of results per page"],
      after: [in: :query, type: :string, description: "Cursor for next page"],
      before: [in: :query, type: :string, description: "Cursor for previous page"]
    ],
    responses: [
      ok: {"Paginated contractors", "application/json", ContractorListResponse}
    ]
  )

  operation(:show,
    summary: "Get a contractor",
    description: "Returns a single contractor by ID",
    parameters: [
      id: [in: :path, type: :string, description: "Contractor ID", required: true]
    ],
    responses: [
      ok: {"Contractor details", "application/json", ContractorResponse},
      not_found: {"Not found", "application/json", ProblemDetail}
    ]
  )

  operation(:update,
    summary: "Update a contractor",
    description: "Updates an existing contractor's details",
    parameters: [
      id: [in: :path, type: :string, description: "Contractor ID", required: true]
    ],
    request_body: {"Contractor update params", "application/json", ContractorUpdateRequest},
    responses: [
      ok: {"Updated contractor", "application/json", ContractorResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:activate,
    summary: "Activate a contractor",
    description: "Transitions a contractor from draft to active status",
    parameters: [
      id: [in: :path, type: :string, description: "Contractor ID", required: true]
    ],
    responses: [
      ok: {"Activated contractor", "application/json", ContractorResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

  operation(:offboard,
    summary: "Offboard a contractor",
    description: "Transitions a contractor to offboarded status",
    parameters: [
      id: [in: :path, type: :string, description: "Contractor ID", required: true]
    ],
    responses: [
      ok: {"Offboarded contractor", "application/json", ContractorResponse},
      not_found: {"Not found", "application/json", ProblemDetail},
      unprocessable_entity: {"Validation error", "application/json", ValidationError}
    ]
  )

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
           Contractors.update_contractor(
             conn.assigns.current_company_id,
             id,
             contractor_params,
             context
           ) do
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
