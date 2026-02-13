defmodule ContractorHubWeb.Schemas.AuditLogData do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "AuditLogData",
    description: "Audit log entry fields",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      actor_type: %OpenApiSpex.Schema{type: :string},
      actor_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      action: %OpenApiSpex.Schema{type: :string},
      resource_type: %OpenApiSpex.Schema{type: :string},
      resource_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      changes: %OpenApiSpex.Schema{type: :object, nullable: true},
      metadata: %OpenApiSpex.Schema{type: :object, nullable: true},
      inserted_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :actor_type,
      :actor_id,
      :action,
      :resource_type,
      :resource_id,
      :inserted_at
    ]
  })
end

defmodule ContractorHubWeb.Schemas.AuditLogListResponse do
  require OpenApiSpex

  alias ContractorHubWeb.Schemas.PaginationMeta

  OpenApiSpex.schema(%{
    title: "AuditLogListResponse",
    description: "Paginated list of audit log entries",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{
        type: :array,
        items: ContractorHubWeb.Schemas.AuditLogData
      },
      meta: PaginationMeta
    },
    required: [:data, :meta]
  })
end
