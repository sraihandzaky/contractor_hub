defmodule ContractorHub.CompaniesTest do
  use ContractorHub.DataCase, async: true

  alias ContractorHub.Companies

  describe "register_company/1" do
    test "creates company and API key" do
      attrs = %{
        "name" => "Acme Corp",
        "email" => "admin@acme.com",
        "country_code" => "US"
      }

      assert {:ok, company, raw_key} = Companies.register_company(attrs)
      assert company.name == "Acme Corp"
      assert company.base_currency == "USD"
      assert String.starts_with?(raw_key, "chub_sk_")
    end

    test "fails with duplicate email" do
      attrs = %{"name" => "Acme", "email" => "dup@test.com", "country_code" => "US"}
      assert {:ok, _, _} = Companies.register_company(attrs)
      assert {:error, changeset} = Companies.register_company(attrs)
      assert errors_on(changeset).email != []
    end
  end

  describe "update_company/2" do
    test "updates company fields" do
      {:ok, company, _} = Companies.register_company(%{
        "name" => "Old Name", "email" => "test@test.com", "country_code" => "US"
      })

      assert {:ok, updated} = Companies.update_company(company, %{"name" => "New Name"})
      assert updated.name == "New Name"
    end
  end

  describe "deactivate_company/1" do
    test "sets deleted_at" do
      {:ok, company, _} = Companies.register_company(%{
        "name" => "Dying Corp", "email" => "bye@test.com", "country_code" => "US"
      })

      assert is_nil(company.deleted_at)
      assert {:ok, deactivated} = Companies.deactivate_company(company)
      assert deactivated.deleted_at != nil
    end
  end

  describe "get_active_company/1" do
    test "returns nil for deactivated companies" do
      {:ok, company, _} = Companies.register_company(%{
        "name" => "Gone Corp", "email" => "gone@test.com", "country_code" => "US"
      })

      Companies.deactivate_company(company)
      assert is_nil(Companies.get_active_company(company.id))
    end
  end
end
