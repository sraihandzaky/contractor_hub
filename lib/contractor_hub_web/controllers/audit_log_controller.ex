defmodule ContractorHubWeb.AuditLogController do
  use ContractorHubWeb, :controller

  alias ContractorHub.Audit

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
