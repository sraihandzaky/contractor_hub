defmodule ContractorHub.FiltersTest do
  use ContractorHub.DataCase, async: true

  import ContractorHub.Factory

  alias ContractorHub.{Filters, Repo}
  alias ContractorHub.Contractors.Contractor

  setup do
    company = insert(:company)
    insert(:contractor, company: company, country_code: "US", status: "active", tax_id: "111-11-1111")
    insert(:contractor, company: company, country_code: "DE", status: "pending", tax_id: "12345678901")
    insert(:contractor, company: company, country_code: "US", status: "pending", tax_id: "222-22-2222")
    {:ok, company: company}
  end

  defp filters do
    [
      {"country_code", Filters.eq(:country_code)},
      {"status", Filters.eq(:status)},
      {"search", Filters.ilike(:full_name)}
    ]
  end


  test "eq filter matches exact value", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"country_code" => "US"}, filters())
      |> Repo.all()

    assert length(result) == 2
  end

  test "returns all when filter param is nil", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{}, filters())
      |> Repo.all()

    assert length(result) == 3
  end

  test "returns all when filter param is empty string", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"country_code" => ""}, filters())
      |> Repo.all()

    assert length(result) == 3
  end

  test "multiple filters combine with AND", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"country_code" => "US", "status" => "active"}, filters())
      |> Repo.all()

    assert length(result) == 1
  end

  test "ilike filter does case-insensitive partial match", %{company: company} do
    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"search" => "Contractor"}, filters())
      |> Repo.all()

    # All factory contractors have "Contractor N" as full_name
    assert length(result) == 3
  end

  test "in_list filter matches comma-separated values", %{company: company} do
    filter_list = [{"country_code", Filters.in_list(:country_code)}]

    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"country_code" => "US,DE"}, filter_list)
      |> Repo.all()

    assert length(result) == 3
  end

  test "date_gte ignores invalid date string", %{company: company} do
    filter_list = [{"start", Filters.date_gte(:inserted_at)}]

    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"start" => "not-a-date"}, filter_list)
      |> Repo.all()

    assert length(result) == 3
  end

  test "date_lte ignores invalid date string", %{company: company} do
    filter_list = [{"end", Filters.date_lte(:inserted_at)}]

    result =
      Contractor
      |> ContractorHub.Scope.for_company(company.id)
      |> Filters.apply_filters(%{"end" => "31-31-2099"}, filter_list)
      |> Repo.all()

    assert length(result) == 3
  end
end
