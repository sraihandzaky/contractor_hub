defmodule ContractorHub.ContractorsTest do
  use ContractorHub.DataCase, async: true

  import ContractorHub.Factory

  alias ContractorHub.Contractors

  @context %{company_id: nil, api_key_id: nil, metadata: %{}}

  setup do
    {company, _key} = insert_company_with_api_key()
    {:ok, company: company, context: %{@context | company_id: company.id, api_key_id: 1}}
  end

  describe "onboard_contractor/2" do
    test "creates contractor with valid attributes and audit log", %{context: ctx} do
      attrs = %{
        "email" => "john@example.com",
        "full_name" => "John Doe",
        "country_code" => "US",
        "tax_id" => "123-45-6789"
      }

      assert {:ok, contractor} = Contractors.onboard_contractor(attrs, ctx)
      assert contractor.status == "pending"
      assert contractor.company_id == ctx.company_id

      # Verify audit log was created
      [log] = ContractorHub.Repo.all(ContractorHub.Audit.AuditLog)
      assert log.action == "contractor.created"
      assert log.resource_type == "contractor"
      assert log.resource_id == contractor.id
    end

    test "fails without tax_id for countries that require it", %{context: ctx} do
      attrs = %{
        "email" => "hans@example.com",
        "full_name" => "Hans Mueller",
        "country_code" => "DE"
      }

      assert {:error, changeset} = Contractors.onboard_contractor(attrs, ctx)
      assert "Steuernummer is required for Germany" in errors_on(changeset).tax_id
    end

    test "fails without NPWP for Indonesia", %{context: ctx} do
      attrs = %{
        "email" => "budi@example.com",
        "full_name" => "Budi Santoso",
        "country_code" => "ID"
      }

      assert {:error, changeset} = Contractors.onboard_contractor(attrs, ctx)
      assert "NPWP is required for Indonesia" in errors_on(changeset).tax_id
    end

    test "enforces unique email per company", %{company: company, context: ctx} do
      insert(:contractor, company: company, email: "dup@example.com")

      attrs = %{
        "email" => "dup@example.com",
        "full_name" => "Another Person",
        "country_code" => "US",
        "tax_id" => "999-99-9999"
      }

      assert {:error, changeset} = Contractors.onboard_contractor(attrs, ctx)
      assert errors_on(changeset).email != []
    end

    test "rejects unsupported country codes", %{context: ctx} do
      attrs = %{
        "email" => "test@example.com",
        "full_name" => "Test",
        "country_code" => "ZZ"
      }

      assert {:error, changeset} = Contractors.onboard_contractor(attrs, ctx)
      assert "is not a supported country" in errors_on(changeset).country_code
    end
  end

  describe "offboard_contractor/3" do
    test "transitions active contractor to offboarded", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company, status: "active")

      assert {:ok, offboarded} = Contractors.offboard_contractor(company.id, contractor.id, ctx)
      assert offboarded.status == "offboarded"
    end

    test "cannot offboard already offboarded contractor", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company, status: "offboarded")

      assert {:error, changeset} = Contractors.offboard_contractor(company.id, contractor.id, ctx)
      assert errors_on(changeset).status != []
    end

    test "cannot access contractor from different company", %{context: ctx} do
      other_company = insert(:company)
      contractor = insert(:contractor, company: other_company, status: "active")

      assert {:error, :not_found} =
               Contractors.offboard_contractor(ctx.company_id, contractor.id, ctx)
    end
  end

  describe "list_contractors/2" do
    test "only returns contractors for the given company", %{company: company} do
      insert_list(3, :contractor, company: company)
      insert_list(2, :contractor)

      result = Contractors.list_contractors(company.id)
      assert length(result.data) == 3
    end

    test "filters by country_code", %{company: company} do
      insert(:contractor, company: company, country_code: "US", tax_id: "111-11-1111")
      insert(:contractor, company: company, country_code: "ID", tax_id: "12.345.678.9-012.345")
      insert(:contractor, company: company, country_code: "US", tax_id: "222-22-2222")

      result = Contractors.list_contractors(company.id, %{"country_code" => "US"})
      assert length(result.data) == 2
    end

    test "filters by status", %{company: company} do
      insert(:contractor, company: company, status: "active")
      insert(:contractor, company: company, status: "pending")

      result = Contractors.list_contractors(company.id, %{"status" => "active"})
      assert length(result.data) == 1
    end

    test "paginates with cursor", %{company: company} do
      insert_list(5, :contractor, company: company)

      page1 = Contractors.list_contractors(company.id, %{"limit" => "2"})
      assert length(page1.data) == 2
      assert page1.meta.has_next == true

      page2 = Contractors.list_contractors(company.id, %{"limit" => "2", "after" => page1.meta.next_cursor})
      assert length(page2.data) == 2

      page1_ids = Enum.map(page1.data, & &1.id)
      page2_ids = Enum.map(page2.data, & &1.id)
      assert MapSet.disjoint?(MapSet.new(page1_ids), MapSet.new(page2_ids))
    end
  end
end
