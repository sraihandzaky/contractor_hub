defmodule ContractorHubWeb.AuditLogController do
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHub.Audit
  alias ContractorHubWeb.Schemas.{AuditLogListResponse, ProblemDetail}

  tags ["Audit Logs"]

  operation :index,
    summary: "List audit logs",
    description: "Returns a paginated list of audit log entries for the authenticated company",
    parameters: [
      resource_type: [in: :query, type: :string, description: "Filter by resource type (e.g. contractor, contract)"],
      resource_id: [in: :query, type: :string, description: "Filter by resource ID"],
      action: [in: :query, type: :string, description: "Filter by action"],
      limit: [in: :query, type: :integer, description: "Number of results per page"],
      after: [in: :query, type: :string, description: "Cursor for next page"],
      before: [in: :query, type: :string, description: "Cursor for previous page"]
    ],
    responses: [
      ok: {"Paginated audit logs", "application/json", AuditLogListResponse},
      unauthorized: {"Unauthorized", "application/json", ProblemDetail}
    ]

  def index(conn, params) do
    page = Audit.list_logs(conn.assigns.current_company_id, params)

    json(conn, %{
      data: Enum.map(page.data, &audit_log_data/1),
      meta: page.meta
    })
  end

  defp audit_log_data(log) do
    %{
      id: log.id,
      actor_type: log.actor_type,
      actor_id: log.actor_id,
      action: log.action,
      resource_type: log.resource_type,
      resource_id: log.resource_id,
      changes: log.changes,
      metadata: log.metadata,
      inserted_at: log.inserted_at
    }
  end
end
