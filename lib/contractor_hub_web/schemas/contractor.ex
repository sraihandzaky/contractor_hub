defmodule ContractorHubWeb.Schemas.ContractorData do
  @moduledoc "OpenAPI schema for contractor data fields."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractorData",
    description: "Contractor data fields",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      email: %OpenApiSpex.Schema{type: :string, format: :email},
      full_name: %OpenApiSpex.Schema{type: :string},
      country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
      tax_id: %OpenApiSpex.Schema{type: :string, nullable: true},
      bank_details: %OpenApiSpex.Schema{type: :object, nullable: true},
      status: %OpenApiSpex.Schema{
        type: :string,
        enum: ["draft", "active", "offboarded"]
      },
      inserted_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
      updated_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :email, :full_name, :country_code, :status, :inserted_at, :updated_at]
  })
end

defmodule ContractorHubWeb.Schemas.ContractorResponse do
  @moduledoc "OpenAPI schema for a single contractor response."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractorResponse",
    description: "Single contractor response",
    type: :object,
    properties: %{
      data: ContractorHubWeb.Schemas.ContractorData
    },
    required: [:data]
  })
end

defmodule ContractorHubWeb.Schemas.ContractorListResponse do
  @moduledoc "OpenAPI schema for a paginated list of contractors."
  require OpenApiSpex

  alias ContractorHubWeb.Schemas.PaginationMeta

  OpenApiSpex.schema(%{
    title: "ContractorListResponse",
    description: "Paginated list of contractors",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{
        type: :array,
        items: ContractorHubWeb.Schemas.ContractorData
      },
      meta: PaginationMeta
    },
    required: [:data, :meta]
  })
end

defmodule ContractorHubWeb.Schemas.ContractorRequest do
  @moduledoc "OpenAPI schema for contractor creation requests."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractorRequest",
    description: "Contractor creation request body",
    type: :object,
    properties: %{
      contractor: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          email: %OpenApiSpex.Schema{type: :string, format: :email},
          full_name: %OpenApiSpex.Schema{type: :string},
          country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
          tax_id: %OpenApiSpex.Schema{type: :string},
          bank_details: %OpenApiSpex.Schema{type: :object}
        },
        required: [:email, :full_name, :country_code]
      }
    },
    required: [:contractor]
  })
end

defmodule ContractorHubWeb.Schemas.ContractorUpdateRequest do
  @moduledoc "OpenAPI schema for contractor update requests."
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractorUpdateRequest",
    description: "Contractor update request body",
    type: :object,
    properties: %{
      contractor: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          email: %OpenApiSpex.Schema{type: :string, format: :email},
          full_name: %OpenApiSpex.Schema{type: :string},
          country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
          tax_id: %OpenApiSpex.Schema{type: :string},
          bank_details: %OpenApiSpex.Schema{type: :object}
        }
      }
    },
    required: [:contractor]
  })
end
