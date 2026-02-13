defmodule ContractorHubWeb.Schemas.ContractData do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractData",
    description: "Contract data fields",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      contractor_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      title: %OpenApiSpex.Schema{type: :string},
      description: %OpenApiSpex.Schema{type: :string, nullable: true},
      rate_amount: %OpenApiSpex.Schema{type: :string, description: "Decimal amount as string"},
      rate_currency: %OpenApiSpex.Schema{type: :string, example: "USD"},
      rate_type: %OpenApiSpex.Schema{
        type: :string,
        enum: ["hourly", "daily", "weekly", "monthly", "fixed"]
      },
      start_date: %OpenApiSpex.Schema{type: :string, format: :date},
      end_date: %OpenApiSpex.Schema{type: :string, format: :date, nullable: true},
      status: %OpenApiSpex.Schema{
        type: :string,
        enum: ["draft", "active", "completed", "terminated"]
      },
      country_rules: %OpenApiSpex.Schema{type: :object, nullable: true},
      inserted_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
      updated_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :contractor_id,
      :title,
      :rate_amount,
      :rate_currency,
      :rate_type,
      :start_date,
      :status,
      :inserted_at,
      :updated_at
    ]
  })
end

defmodule ContractorHubWeb.Schemas.ContractResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractResponse",
    description: "Single contract response",
    type: :object,
    properties: %{
      data: ContractorHubWeb.Schemas.ContractData
    },
    required: [:data]
  })
end

defmodule ContractorHubWeb.Schemas.ContractListResponse do
  require OpenApiSpex

  alias ContractorHubWeb.Schemas.PaginationMeta

  OpenApiSpex.schema(%{
    title: "ContractListResponse",
    description: "Paginated list of contracts",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{
        type: :array,
        items: ContractorHubWeb.Schemas.ContractData
      },
      meta: PaginationMeta
    },
    required: [:data, :meta]
  })
end

defmodule ContractorHubWeb.Schemas.ContractRequest do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractRequest",
    description: "Contract creation request body",
    type: :object,
    properties: %{
      contract: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          contractor_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
          title: %OpenApiSpex.Schema{type: :string},
          description: %OpenApiSpex.Schema{type: :string},
          rate_amount: %OpenApiSpex.Schema{type: :string, description: "Decimal amount as string"},
          rate_currency: %OpenApiSpex.Schema{type: :string, example: "USD"},
          rate_type: %OpenApiSpex.Schema{
            type: :string,
            enum: ["hourly", "daily", "weekly", "monthly", "fixed"]
          },
          start_date: %OpenApiSpex.Schema{type: :string, format: :date},
          end_date: %OpenApiSpex.Schema{type: :string, format: :date}
        },
        required: [:contractor_id, :title, :rate_amount, :rate_currency, :rate_type, :start_date]
      }
    },
    required: [:contract]
  })
end

defmodule ContractorHubWeb.Schemas.ContractUpdateRequest do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ContractUpdateRequest",
    description: "Contract update request body",
    type: :object,
    properties: %{
      contract: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          title: %OpenApiSpex.Schema{type: :string},
          description: %OpenApiSpex.Schema{type: :string},
          rate_amount: %OpenApiSpex.Schema{type: :string, description: "Decimal amount as string"},
          rate_currency: %OpenApiSpex.Schema{type: :string, example: "USD"},
          rate_type: %OpenApiSpex.Schema{
            type: :string,
            enum: ["hourly", "daily", "weekly", "monthly", "fixed"]
          },
          start_date: %OpenApiSpex.Schema{type: :string, format: :date},
          end_date: %OpenApiSpex.Schema{type: :string, format: :date}
        }
      }
    },
    required: [:contract]
  })
end
