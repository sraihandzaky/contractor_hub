defmodule ContractorHubWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server, SecurityScheme, Components}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "ContractorHub API",
        version: "1.0.0",
        description: """
        Global contractor management API for onboarding, contract lifecycle,
        and payment processing across multiple jurisdictions.
        """
      },
      servers: [
        %Server{url: "http://localhost:4000", description: "Development"},
        %Server{url: "https://contractor-hub-api.fly.dev", description: "Production"}
      ],
      components: %Components{
        securitySchemes: %{
          "bearer" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            description: "API key obtained during company registration"
          }
        }
      },
      security: [%{"bearer" => []}],
      paths: Paths.from_router(ContractorHubWeb.Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
