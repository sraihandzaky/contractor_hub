defmodule ContractorHubWeb.CompanyJSON do
  def render("show.json", %{company: company}) do
    %{data: data(company)}
  end

  def render("show_with_key.json", %{company: company, api_key: api_key}) do
    %{
      data: data(company),
      api_key: api_key
    }
  end

  defp data(company) do
    %{
      id: company.id,
      name: company.name,
      email: company.email,
      country_code: company.country_code,
      base_currency: company.base_currency,
      inserted_at: company.inserted_at,
      updated_at: company.updated_at
    }
  end
end
