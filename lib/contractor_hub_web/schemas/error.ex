defmodule ContractorHubWeb.Schemas.ProblemDetail do
  @moduledoc "OpenAPI schema for RFC 9457 problem detail error responses."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ProblemDetail",
    description: "RFC 9457 Problem Detail",
    type: :object,
    properties: %{
      type: %OpenApiSpex.Schema{type: :string, description: "Error type identifier"},
      title: %OpenApiSpex.Schema{type: :string, description: "Short human-readable summary"},
      status: %OpenApiSpex.Schema{type: :integer, description: "HTTP status code"},
      detail: %OpenApiSpex.Schema{type: :string, description: "Human-readable explanation"}
    },
    required: [:type, :title, :status, :detail],
    example: %{
      type: "not_found",
      title: "Not Found",
      status: 404,
      detail: "Resource not found"
    }
  })
end

defmodule ContractorHubWeb.Schemas.ValidationError do
  @moduledoc "OpenAPI schema for validation error responses with field-level details."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ValidationError",
    description: "Validation error with field-level details",
    type: :object,
    properties: %{
      type: %OpenApiSpex.Schema{type: :string},
      title: %OpenApiSpex.Schema{type: :string},
      status: %OpenApiSpex.Schema{type: :integer},
      detail: %OpenApiSpex.Schema{type: :string},
      errors: %OpenApiSpex.Schema{
        type: :object,
        description: "Map of field names to error messages",
        additionalProperties: %OpenApiSpex.Schema{
          type: :array,
          items: %OpenApiSpex.Schema{type: :string}
        }
      }
    },
    required: [:type, :title, :status, :detail, :errors],
    example: %{
      type: "validation_error",
      title: "Unprocessable Entity",
      status: 422,
      detail: "Request validation failed",
      errors: %{email: ["has already been taken"]}
    }
  })
end
