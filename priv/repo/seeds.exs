# Run: mix run priv/repo/seeds.exs
# Seed the DB with data.

alias ContractorHub.Repo
alias ContractorHub.Companies.Company
alias ContractorHub.Contractors.Contractor
alias ContractorHub.Contracts.Contract
alias ContractorHub.Auth.ApiKey

IO.puts("Seeding ContractorHub...")

# Demo Company
{:ok, company} =
  %Company{}
  |> Company.changeset(%{
    name: "Acme Global Inc.",
    email: "admin@acmeglobal.com",
    country_code: "US",
    base_currency: "USD"
  })
  |> Repo.insert()

# Create a demo API key for dev
raw_key = "chub_sk_demo_acme_2025"
key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode16(case: :lower)

{:ok, _api_key} =
  %ApiKey{}
  |> ApiKey.changeset(%{
    company_id: company.id,
    key_hash: key_hash,
    label: "Demo Key"
  })
  |> Repo.insert()

IO.puts("Company: #{company.name}")
IO.puts("Demo API Key: #{raw_key}")

# Contractors across different countries
contractors_data = [
  %{
    full_name: "Sarah Chen",
    email: "sarah@example.com",
    country_code: "US",
    tax_id: "123-45-6789",
    status: "active"
  },
  %{
    full_name: "Hans Mueller",
    email: "hans@example.com",
    country_code: "DE",
    tax_id: "12345678901",
    status: "active"
  },
  %{
    full_name: "Ana Silva",
    email: "ana@example.com",
    country_code: "BR",
    tax_id: "123.456.789-00",
    status: "active"
  },
  %{
    full_name: "Budi Santoso",
    email: "budi@example.com",
    country_code: "ID",
    tax_id: "12.345.678.9-012.345",
    status: "active"
  },
  %{
    full_name: "James Wilson",
    email: "james@example.com",
    country_code: "GB",
    tax_id: "1234567890",
    status: "pending"
  },
  %{
    full_name: "Wei Lin Tan",
    email: "weilin@example.com",
    country_code: "SG",
    tax_id: "S1234567A",
    status: "active"
  },
  %{
    full_name: "Emma de Vries",
    email: "emma@example.com",
    country_code: "NL",
    tax_id: "123456789",
    status: "active"
  },
  %{
    full_name: "David Thompson",
    email: "david@example.com",
    country_code: "CA",
    tax_id: "123-456-789",
    status: "offboarded"
  }
]

contractors =
  Enum.map(contractors_data, fn data ->
    {:ok, contractor} =
      %Contractor{}
      |> Contractor.changeset(Map.put(data, :company_id, company.id))
      |> Repo.insert()

    IO.puts(
      "Contractor: #{contractor.full_name} (#{contractor.country_code}) [#{contractor.status}]"
    )

    contractor
  end)

# Contracts for active contractors
active_contractors = Enum.filter(contractors, &(&1.status == "active"))

contracts_data = [
  %{
    title: "Senior Frontend Engineer",
    rate_amount: "8000.00",
    rate_currency: "USD",
    rate_type: "monthly"
  },
  %{
    title: "Backend Consultant",
    rate_amount: "120.00",
    rate_currency: "EUR",
    rate_type: "hourly"
  },
  %{title: "Data Analyst", rate_amount: "15000.00", rate_currency: "BRL", rate_type: "monthly"},
  %{
    title: "Mobile Developer",
    rate_amount: "45000000.00",
    rate_currency: "IDR",
    rate_type: "monthly"
  },
  %{title: "DevOps Engineer", rate_amount: "95.00", rate_currency: "GBP", rate_type: "hourly"},
  %{title: "QA Lead", rate_amount: "7500.00", rate_currency: "SGD", rate_type: "monthly"}
]

Enum.zip(active_contractors, contracts_data)
|> Enum.each(fn {contractor, contract_data} ->
  {:ok, contract} =
    %Contract{}
    |> Contract.changeset(
      contract_data
      |> Map.merge(%{
        company_id: company.id,
        contractor_id: contractor.id,
        rate_amount: Decimal.new(contract_data.rate_amount),
        start_date: Date.add(Date.utc_today(), -30),
        end_date: Date.add(Date.utc_today(), 335),
        status: "active"
      })
    )
    |> Repo.insert()

  IO.puts(
    "Contract: #{contract.title} (#{contract.rate_currency} #{contract.rate_amount}/#{contract.rate_type})"
  )
end)

IO.puts("")
IO.puts("Seeding complete!")
IO.puts("")
IO.puts("Try the API:")
IO.puts("  curl -H 'Authorization: Bearer #{raw_key}' http://localhost:4000/api/v1/contractors")
IO.puts("  curl http://localhost:4000/api/v1/countries")
IO.puts("  Open http://localhost:4000/api/docs for Swagger UI")
