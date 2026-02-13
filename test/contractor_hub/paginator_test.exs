defmodule ContractorHub.PaginatorTest do
  use ContractorHub.DataCase, async: true

  import ContractorHub.Factory

  alias ContractorHub.Paginator
  alias ContractorHub.Contractors.Contractor

  setup do
    company = insert(:company)
    # Insert 5 contractors with slight time gaps
    for _ <- 1..5 do
      insert(:contractor, company: company)
    end

    {:ok, company: company}
  end

  test "returns default limit of records", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{})

    assert length(result.data) == 5
    assert result.meta.limit == 20
  end

  test "respects custom limit", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"limit" => "2"})

    assert length(result.data) == 2
    assert result.meta.has_next == true
  end

  test "cursor encode/decode roundtrip" do
    # Build a fake record with id and inserted_at
    record = %{id: 42, inserted_at: ~N[2025-06-15 10:30:00]}

    encoded =
      %{id: record.id, inserted_at: record.inserted_at}
      |> Jason.encode!()
      |> Base.url_encode64(padding: false)

    decoded = encoded |> Base.url_decode64!(padding: false) |> Jason.decode!()

    assert decoded["id"] == 42
  end

  test "paginates with after cursor and have no overlap", %{company: company} do
    page1 =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"limit" => "2"})

    assert length(page1.data) == 2
    assert page1.meta.has_next == true
    assert page1.meta.next_cursor != nil

    page2 =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"limit" => "2", "after" => page1.meta.next_cursor})

    assert length(page2.data) == 2

    # No overlap between pages
    page1_ids = Enum.map(page1.data, & &1.id)
    page2_ids = Enum.map(page2.data, & &1.id)
    assert MapSet.disjoint?(MapSet.new(page1_ids), MapSet.new(page2_ids))
  end

  test "returns empty page for empty results" do
    # Query a company with no contractors
    company = insert(:company)

    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{})

    assert result.data == []
    assert result.meta.has_next == false
  end

  test "single page sets has_next to false", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{})

    assert length(result.data) == 5
    assert result.meta.has_next == false
    assert result.meta.next_cursor != nil
  end

  test "invalid cursor falls back to first page", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"after" => "not-valid-base64!!"})

    assert length(result.data) == 5
  end

  test "clamps limit to max of 100", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"limit" => "999"})

    # Should use default limit since 999 > max
    assert result.meta.limit == 20
  end

  test "handles invalid limit gracefully", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Paginator.paginate(%{"limit" => "abc"})

    assert result.meta.limit == 20
  end
end
