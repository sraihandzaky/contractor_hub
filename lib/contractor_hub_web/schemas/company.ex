defmodule ContractorHubWeb.Schemas.CompanyData do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyData",
    description: "Company data fields",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      name: %OpenApiSpex.Schema{type: :string},
      email: %OpenApiSpex.Schema{type: :string, format: :email},
      country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
      base_currency: %OpenApiSpex.Schema{type: :string, example: "USD"},
      inserted_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
      updated_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :name, :email, :country_code, :base_currency, :inserted_at, :updated_at]
  })
end

defmodule ContractorHubWeb.Schemas.CompanyResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyResponse",
    description: "Single company response",
    type: :object,
    properties: %{
      data: ContractorHubWeb.Schemas.CompanyData
    },
    required: [:data]
  })
end

defmodule ContractorHubWeb.Schemas.CompanyWithKeyResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyWithKeyResponse",
    description: "Company registration response including the API key",
    type: :object,
    properties: %{
      data: ContractorHubWeb.Schemas.CompanyData,
      api_key: %OpenApiSpex.Schema{
        type: :string,
        description: "API key for authenticating future requests. Store securely — it cannot be retrieved again."
      }
    },
    required: [:data, :api_key]
  })
end

defmodule ContractorHubWeb.Schemas.CompanyRequest do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyRequest",
    description: "Company registration request body",
    type: :object,
    properties: %{
      company: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          name: %OpenApiSpex.Schema{type: :string},
          email: %OpenApiSpex.Schema{type: :string, format: :email},
          country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
          base_currency: %OpenApiSpex.Schema{type: :string, example: "USD"}
        },
        required: [:name, :email, :country_code, :base_currency]
      }
    },
    required: [:company]
  })
end

defmodule ContractorHubWeb.Schemas.CompanyUpdateRequest do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyUpdateRequest",
    description: "Company update request body",
    type: :object,
    properties: %{
      company: %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          name: %OpenApiSpex.Schema{type: :string},
          email: %OpenApiSpex.Schema{type: :string, format: :email},
          country_code: %OpenApiSpex.Schema{type: :string, example: "US"},
          base_currency: %OpenApiSpex.Schema{type: :string, example: "USD"}
        }
      }
    },
    required: [:company]
  })
end
