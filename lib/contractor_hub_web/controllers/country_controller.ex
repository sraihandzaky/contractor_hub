defmodule ContractorHubWeb.CountryController do
  use ContractorHubWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ContractorHub.Compliance
  alias ContractorHubWeb.Schemas.CountryListResponse

  tags ["Countries"]

  operation :index,
    summary: "List supported countries",
    description: "Returns all countries supported for contractor management",
    security: [],
    responses: [
      ok: {"List of countries", "application/json", CountryListResponse}
    ]

  def index(conn, _params) do
    json(conn, %{data: Compliance.list_countries()})
  end
end
