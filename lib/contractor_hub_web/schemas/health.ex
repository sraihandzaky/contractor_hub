defmodule ContractorHubWeb.Schemas.HealthResponse do
  @moduledoc "OpenAPI schema for the health check response."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "HealthResponse",
    description: "Health check response",
    type: :object,
    properties: %{
      status: %OpenApiSpex.Schema{type: :string, example: "ok"},
      timestamp: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [:status, :timestamp]
  })
end
