defmodule ContractorHubWeb.Schemas.PaginationMeta do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "PaginationMeta",
    description: "Cursor-based pagination metadata",
    type: :object,
    properties: %{
      has_next: %OpenApiSpex.Schema{type: :boolean},
      has_prev: %OpenApiSpex.Schema{type: :boolean},
      next_cursor: %OpenApiSpex.Schema{type: :string, nullable: true},
      prev_cursor: %OpenApiSpex.Schema{type: :string, nullable: true}
    },
    required: [:has_next, :has_prev]
  })
end
