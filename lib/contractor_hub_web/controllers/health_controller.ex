defmodule ContractorHubWeb.HealthController do
  @moduledoc "Handles health check requests."
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHubWeb.Schemas.HealthResponse

  tags(["Health"])

  operation(:show,
    summary: "Health check",
    description: "Returns the current health status of the API",
    security: [],
    responses: [
      ok: {"Health status", "application/json", HealthResponse}
    ]
  )

  def show(conn, _params) do
    json(conn, %{status: "ok", timestamp: DateTime.utc_now()})
  end
end
