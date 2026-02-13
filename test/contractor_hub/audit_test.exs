defmodule ContractorHub.AuditTest do
  use ContractorHub.DataCase, async: true

  import ContractorHub.Factory

  alias ContractorHub.Audit

  setup do
    {company, _key} = insert_company_with_api_key()
    context = %{company_id: company.id, api_key_id: 1, metadata: %{}}

    # Create audit logs by onboarding contractors
    {:ok, contractor} =
      ContractorHub.Contractors.onboard_contractor(
        %{
          "email" => "a@test.com",
          "full_name" => "A",
          "country_code" => "US",
          "tax_id" => "111-11-1111"
        },
        context
      )

    {:ok, _} =
      ContractorHub.Contractors.activate_contractor(company.id, contractor.id, context)

    {:ok, company: company}
  end

  test "lists audit logs for a company", %{company: company} do
    page = Audit.list_logs(company.id, %{})
    assert length(page.data) == 2
  end

  test "filters audit logs by action", %{company: company} do
    page = Audit.list_logs(company.id, %{"action" => "contractor.created"})
    assert length(page.data) == 1
    assert hd(page.data).action == "contractor.created"
  end

  test "filters audit logs by resource_type", %{company: company} do
    page = Audit.list_logs(company.id, %{"resource_type" => "contractor"})
    assert length(page.data) == 2
  end
end
