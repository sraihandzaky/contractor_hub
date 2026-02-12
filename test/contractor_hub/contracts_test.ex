defmodule ContractorHub.ContractsTest do
  use ContractorHub.DataCase, async: true

  import ContractorHub.Factory

  alias ContractorHub.Contracts

  setup do
    {company, _key} = insert_company_with_api_key()
    context = %{company_id: company.id, api_key_id: 1, metadata: %{}}
    {:ok, company: company, context: context}
  end

  describe "create_contract/2" do
    test "creates contract with valid attrs and audit log", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company, status: "active")

      attrs = %{
        "contractor_id" => contractor.id,
        "title" => "Senior Engineer",
        "rate_amount" => "8000.00",
        "rate_currency" => "USD",
        "rate_type" => "monthly",
        "start_date" => "2025-07-01"
      }

      assert {:ok, contract} = Contracts.create_contract(attrs, ctx)
      assert contract.status == "draft"
      assert contract.title == "Senior Engineer"
    end

    test "validates end_date is after start_date", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)

      attrs = %{
        "contractor_id" => contractor.id,
        "title" => "Bad Dates Contract",
        "rate_amount" => "100.00",
        "rate_currency" => "USD",
        "rate_type" => "hourly",
        "start_date" => "2025-06-01",
        "end_date" => "2025-05-01"
      }

      assert {:error, changeset} = Contracts.create_contract(attrs, ctx)
      assert errors_on(changeset).end_date != []
    end

    test "validates rate_amount is positive", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)

      attrs = %{
        "contractor_id" => contractor.id,
        "title" => "Free Work",
        "rate_amount" => "-100.00",
        "rate_currency" => "USD",
        "rate_type" => "hourly",
        "start_date" => "2025-06-01"
      }

      assert {:error, changeset} = Contracts.create_contract(attrs, ctx)
      assert errors_on(changeset).rate_amount != []
    end

    test "validates rate_type is valid", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)

      attrs = %{
        "contractor_id" => contractor.id,
        "title" => "Bad Type",
        "rate_amount" => "100.00",
        "rate_currency" => "USD",
        "rate_type" => "weekly",
        "start_date" => "2025-06-01"
      }

      assert {:error, changeset} = Contracts.create_contract(attrs, ctx)
      assert errors_on(changeset).rate_type != []
    end

    test "cannot create contract for another company's contractor", %{context: ctx} do
      other_company = insert(:company)
      contractor = insert(:contractor, company: other_company)

      attrs = %{
        "contractor_id" => contractor.id,
        "title" => "Cross-company",
        "rate_amount" => "100.00",
        "rate_currency" => "USD",
        "rate_type" => "hourly",
        "start_date" => "2025-06-01"
      }

      assert {:error, :not_found} = Contracts.create_contract(attrs, ctx)
    end
  end

  describe "activate_contract/3" do
    test "activates a draft contract with audit log", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company, status: "active")
      contract = insert(:contract, company: company, contractor: contractor, status: "draft")

      assert {:ok, activated} = Contracts.activate_contract(company.id, contract.id, ctx)
      assert activated.status == "active"
    end

    test "cannot activate a terminated contract", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)
      contract = insert(:contract, company: company, contractor: contractor, status: "terminated")

      assert {:error, changeset} = Contracts.activate_contract(company.id, contract.id, ctx)
      assert errors_on(changeset).status != []
    end
  end

  describe "terminate_contract/3" do
    test "terminates an active contract", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)
      contract = insert(:contract, company: company, contractor: contractor, status: "active")

      assert {:ok, terminated} = Contracts.terminate_contract(company.id, contract.id, ctx)
      assert terminated.status == "terminated"
    end
  end

  describe "complete_contract/3" do
    test "completes an active contract", %{company: company, context: ctx} do
      contractor = insert(:contractor, company: company)
      contract = insert(:contract, company: company, contractor: contractor, status: "active")

      assert {:ok, completed} = Contracts.complete_contract(company.id, contract.id, ctx)
      assert completed.status == "completed"
    end
  end

  describe "multi-tenancy" do
    test "cannot access other company's contracts", %{company: _company, context: ctx} do
      other_company = insert(:company)
      contractor = insert(:contractor, company: other_company)
      contract = insert(:contract, company: other_company, contractor: contractor)

      assert {:error, :not_found} = Contracts.get_contract(ctx.company_id, contract.id)
    end
  end
end
