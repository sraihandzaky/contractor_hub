defmodule ContractorHub.Sorting do
  @moduledoc """
  Composable sorting from URL params.\n
  Format: ?sort=field:direction (e.g. ?sort=inserted_at:desc)
  """
  import Ecto.Query

  @default_sort {:inserted_at, :desc}

  @doc """
  Applies sorting to a query based on URL params.

  ## Example

      Contractor
      |> Sorting.apply(params, [:inserted_at, :full_name, :country_code])
  """
  def apply(queryable, params, allowed_fields) do
    {field, direction} = parse_sort(params, allowed_fields)
    from q in queryable, order_by: [{^direction, field(q, ^field)}]
  end

  defp parse_sort(%{"sort" => sort_param}, allowed_fields) do
    case String.split(sort_param, ":", parts: 2) do
      [field, dir] when dir in ["asc", "desc"] ->
        field_atom = String.to_existing_atom(field)

        if field_atom in allowed_fields do
          {field_atom, String.to_existing_atom(dir)}
        else
          @default_sort
        end

      _ ->
        @default_sort
    end
  rescue
    ArgumentError -> @default_sort
  end

  defp parse_sort(_, _), do: @default_sort
end
