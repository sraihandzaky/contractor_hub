defmodule ContractorHubWeb.Router do
  @moduledoc "Defines API routes and pipelines for the ContractorHub application."
  use ContractorHubWeb, :router

  def api_spec, do: ContractorHubWeb.ApiSpec.spec()

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug ContractorHubWeb.Plugs.Authenticate
  end

  pipeline :openapi do
    plug OpenApiSpex.Plug.PutApiSpec, module: ContractorHubWeb.ApiSpec
  end

  # Public routes (no auth)
  scope "/api/v1", ContractorHubWeb do
    pipe_through :api

    get "/health", HealthController, :show
    post "/companies", CompanyController, :create
    get "/countries", CountryController, :index
  end

  # Protected routes
  scope "/api/v1", ContractorHubWeb do
    pipe_through [:api, :authenticated]

    get "/companies/me", CompanyController, :show
    patch "/companies/me", CompanyController, :update

    resources "/contractors", ContractorController, only: [:create, :index, :show, :update]
    post "/contractors/:id/activate", ContractorController, :activate
    post "/contractors/:id/offboard", ContractorController, :offboard

    resources "/contracts", ContractController, only: [:create, :index, :show, :update]
    post "/contracts/:id/activate", ContractController, :activate
    post "/contracts/:id/complete", ContractController, :complete
    post "/contracts/:id/terminate", ContractController, :terminate

    get "/audit-logs", AuditLogController, :index
  end

  # OpenAPI docs
  scope "/api" do
    pipe_through [:api, :openapi]

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end
end
