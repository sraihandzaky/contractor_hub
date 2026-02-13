defmodule ContractorHubWeb.Schemas.CountryResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CountryResponse",
    description: "Supported country details",
    type: :object,
    properties: %{
      code: %OpenApiSpex.Schema{type: :string, example: "US"},
      name: %OpenApiSpex.Schema{type: :string, example: "United States"},
      currency: %OpenApiSpex.Schema{type: :string, example: "USD"},
      requires_tax_id: %OpenApiSpex.Schema{type: :boolean},
      tax_id_label: %OpenApiSpex.Schema{type: :string, nullable: true, example: "SSN/EIN"},
      payment_methods: %OpenApiSpex.Schema{
        type: :array,
        items: %OpenApiSpex.Schema{type: :string}
      }
    },
    required: [:code, :name, :currency, :requires_tax_id, :payment_methods]
  })
end

defmodule ContractorHubWeb.Schemas.CountryListResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CountryListResponse",
    description: "List of supported countries",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{
        type: :array,
        items: ContractorHubWeb.Schemas.CountryResponse
      }
    },
    required: [:data]
  })
end
