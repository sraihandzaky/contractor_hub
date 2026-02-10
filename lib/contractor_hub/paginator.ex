defmodule ContractorHub.Paginator do
  @moduledoc """
  Cursor-based pagination using (id, inserted_at) pairs.
  # NOTE: Cursor pagination currently uses inserted_at + id for ordering.
  # User-specified sorting via ?sort= applies on the initial page but
  # is overridden once cursor navigation begins.
  # TODO: Invest more time and figure it out how to do this in elixir
  """
  import Ecto.Query

  @default_limit 20
  @max_limit 100

  defmodule Page do
    @moduledoc "Paginated result with data and cursor metadata."
    @derive Jason.Encoder
    defstruct [:data, :meta]
  end

  @doc """
  Paginates a query using cursor-based pagination.

  ## Params

  - `"limit"` — number of items per page (default: 20, max: 100)
  - `"after"` — cursor to fetch items after (next page)
  - `"before"` — cursor to fetch items before (previous page)

  ## Returns

      %Page{
        data: [records...],
        meta: %{
          has_next: true/false,
          has_prev: true/false,
          next_cursor: "encoded...",
          prev_cursor: "encoded...",
          limit: 20
        }
      }
  """
  def paginate(queryable, params) do
    limit = parse_limit(params)
    cursor_dir = if params["before"], do: :before, else: :after

    queryable
    |> apply_cursor(params, cursor_dir)
    |> apply_ordering(cursor_dir)
    |> limit(^(limit + 1))
    |> ContractorHub.Repo.all()
    |> build_page(limit, cursor_dir)
  end

  defp apply_cursor(query, %{"after" => cursor}, :after) when is_binary(cursor) do
    {id, inserted_at} = decode_cursor!(cursor)

    from q in query,
      where:
        q.inserted_at < ^inserted_at or
          (q.inserted_at == ^inserted_at and q.id < ^id)
  end

  defp apply_cursor(query, %{"before" => cursor}, :before) when is_binary(cursor) do
    {id, inserted_at} = decode_cursor!(cursor)

    from q in query,
      where:
        q.inserted_at > ^inserted_at or
          (q.inserted_at == ^inserted_at and q.id > ^id)
  end

  defp apply_cursor(query, _params, _dir), do: query

  defp apply_ordering(query, :before) do
    from q in query, order_by: [asc: q.inserted_at, asc: q.id]
  end

  defp apply_ordering(query, _) do
    from q in query, order_by: [desc: q.inserted_at, desc: q.id]
  end

  defp build_page(records, limit, cursor_dir) do
    has_more = length(records) > limit
    records = Enum.take(records, limit)

    # Reverse if we were paginating backwards
    records = if cursor_dir == :before, do: Enum.reverse(records), else: records

    %Page{
      data: records,
      meta: %{
        has_next: has_more,
        has_prev: cursor_dir != :after or has_more,
        next_cursor: records |> List.last() |> encode_cursor(),
        prev_cursor: records |> List.first() |> encode_cursor(),
        limit: limit
      }
    }
  end

  defp encode_cursor(nil), do: nil

  defp encode_cursor(record) do
    %{id: record.id, inserted_at: record.inserted_at}
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end

  defp decode_cursor!(encoded) do
    decoded = encoded |> Base.url_decode64!(padding: false) |> Jason.decode!()
    {decoded["id"], decoded["inserted_at"]}
  end

  defp parse_limit(%{"limit" => limit}) when is_binary(limit) do
    case Integer.parse(limit) do
      {n, _} when n > 0 and n <= @max_limit -> n
      _ -> @default_limit
    end
  end

  defp parse_limit(_), do: @default_limit
end
