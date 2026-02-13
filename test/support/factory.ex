defmodule ContractorHub.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: ContractorHub.Repo

  def company_factory do
    %ContractorHub.Companies.Company{
      name: sequence(:name, &"Company #{&1}"),
      email: sequence(:email, &"company#{&1}@example.com"),
      country_code: "US",
      base_currency: "USD"
    }
  end

  def contractor_factory do
    %ContractorHub.Contractors.Contractor{
      company: build(:company),
      email: sequence(:email, &"contractor#{&1}@example.com"),
      full_name: sequence(:name, &"Contractor #{&1}"),
      country_code: "US",
      tax_id: sequence(:tax_id, &"#{100 + &1}-45-6789"),
      status: "pending"
    }
  end

  def contract_factory do
    %ContractorHub.Contracts.Contract{
      company: build(:company),
      contractor: build(:contractor),
      title: sequence(:title, &"Contract #{&1}"),
      rate_amount: Decimal.new("5000.00"),
      rate_currency: "USD",
      rate_type: "monthly",
      start_date: Date.utc_today(),
      status: "draft"
    }
  end

  def api_key_factory do
    %ContractorHub.Auth.ApiKey{
      company: build(:company),
      key_hash:
        sequence(:key_hash, &Base.encode16(:crypto.hash(:sha256, "key_#{&1}"), case: :lower)),
      label: "Test Key"
    }
  end

  @doc "Creates a company with a working API key. Returns {company, raw_key}."
  def insert_company_with_api_key do
    company = insert(:company)
    raw_key = "chub_sk_test_#{Base.encode16(:crypto.strong_rand_bytes(16))}"
    hash = :crypto.hash(:sha256, raw_key) |> Base.encode16(case: :lower)

    insert(:api_key, company: company, key_hash: hash)

    {company, raw_key}
  end
end
