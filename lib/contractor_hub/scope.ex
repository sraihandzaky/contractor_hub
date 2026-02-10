defmodule ContractorHub.Scope do
  @moduledoc """
  Multi-tenancy query scoping. Ensures all queries are filtered by company_id.
  Also provides soft-delete filtering for companies.
  """
  import Ecto.Query

  def for_company(queryable, company_id) do
    from q in queryable, where: q.company_id == ^company_id
  end

  @doc "Filter out soft-deleted companies."
  def active(queryable) do
    from q in queryable, where: is_nil(q.deleted_at)
  end
end
