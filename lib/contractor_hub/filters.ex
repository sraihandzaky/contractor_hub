defmodule ContractorHub.Filters do
  @moduledoc """
  Reusable, composable query filters.
  Each filter is a small function that conditionally modifies the query. \n
  Piped together, they build arbitrarily complex queries from URL params.
  """
  import Ecto.Query

  @doc """
  Applies a list of allowed filters to a query based on URL params.

  ## Example

      defp filters do
        [
          {"country_code", Filters.eq(:country_code)},
          {"status", Filters.eq(:status)},
          {"search", Filters.ilike(:full_name)}
        ]
      end

      Contractor
      |> Filters.apply_filters(params, @filters)
  """
  def apply_filters(queryable, params, allowed_filters) do
    Enum.reduce(allowed_filters, queryable, fn {param_key, filter_fn}, query ->
      case Map.get(params, param_key) do
        nil -> query
        "" -> query
        value -> filter_fn.(query, value)
      end
    end)
  end

  # --- Reusable filter builders ---

  @doc "Exact match: WHERE field = value"
  def eq(field) do
    fn query, value ->
      from q in query, where: field(q, ^field) == ^value
    end
  end

  @doc "IN list: WHERE field IN (val1, val2, ...). Values are comma-separated."
  def in_list(field) do
    fn query, value ->
      values = String.split(value, ",", trim: true)
      from q in query, where: field(q, ^field) in ^values
    end
  end

  @doc "Date greater than or equal: WHERE field >= date"
  def date_gte(field) do
    fn query, value ->
      case Date.from_iso8601(value) do
        {:ok, date} -> from q in query, where: field(q, ^field) >= ^date
        _ -> query
      end
    end
  end

  @doc "Date less than or equal: WHERE field <= date"
  def date_lte(field) do
    fn query, value ->
      case Date.from_iso8601(value) do
        {:ok, date} -> from q in query, where: field(q, ^field) <= ^date
        _ -> query
      end
    end
  end

  @doc "Case-insensitive LIKE: WHERE field ILIKE '%value%'"
  def ilike(field) do
    fn query, value ->
      search = "%#{value}%"
      from q in query, where: ilike(field(q, ^field), ^search)
    end
  end
end
