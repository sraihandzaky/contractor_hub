defmodule ContractorHub.SortingTest do
  use ContractorHub.DataCase, async: true

  alias ContractorHub.Sorting
  alias ContractorHub.Contractors.Contractor

  @allowed_fields [:inserted_at, :full_name, :country_code]

  setup do
    company = insert(:company)

    c1 = insert(:contractor, company: company, full_name: "Alice", country_code: "US")

    c2 =
      insert(:contractor,
        company: company,
        full_name: "Bob",
        country_code: "DE",
        tax_id: "12345678901"
      )

    c3 =
      insert(:contractor,
        company: company,
        full_name: "Charlie",
        country_code: "GB",
        tax_id: "1234567890"
      )

    %{company: company, contractors: [c1, c2, c3]}
  end

  test "sorts by inserted_at desc", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "inserted_at:desc"}, @allowed_fields)
      |> Repo.all()

    timestamps = Enum.map(results, & &1.inserted_at)
    assert timestamps == Enum.sort(timestamps, {:desc, NaiveDateTime})
  end

  test "sorts by full_name asc", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "full_name:asc"}, @allowed_fields)
      |> Repo.all()

    names = Enum.map(results, & &1.full_name)
    assert names == ["Alice", "Bob", "Charlie"]
  end

  test "falls back to default for invalid direction", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "inserted_at:invalid"}, @allowed_fields)
      |> Repo.all()

    assert length(results) == 3
  end

  test "falls back to default for disallowed field", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "email:desc"}, @allowed_fields)
      |> Repo.all()

    assert length(results) == 3
  end

  test "falls back to default for nonexistent atom field", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "zzz_nonexistent:desc"}, @allowed_fields)
      |> Repo.all()

    assert length(results) == 3
  end

  test "uses default sort when no sort param given", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{}, @allowed_fields)
      |> Repo.all()

    assert length(results) == 3
  end

  test "falls back to default for malformed format", %{company: company} do
    results =
      Contractor
      |> where([c], c.company_id == ^company.id)
      |> Sorting.apply(%{"sort" => "no-colon"}, @allowed_fields)
      |> Repo.all()

    assert length(results) == 3
  end
end
