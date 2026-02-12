defmodule ContractorHubWeb.ContractJSON do
  def render("index.json", %{page: page}) do
    %{
      data: Enum.map(page.data, &data/1),
      meta: page.meta
    }
  end

  def render("show.json", %{contract: contract}) do
    %{data: data(contract)}
  end

  defp data(contract) do
    %{
      id: contract.id,
      contractor_id: contract.contractor_id,
      title: contract.title,
      description: contract.description,
      rate_amount: contract.rate_amount,
      rate_currency: contract.rate_currency,
      rate_type: contract.rate_type,
      start_date: contract.start_date,
      end_date: contract.end_date,
      status: contract.status,
      country_rules: contract.country_rules,
      inserted_at: contract.inserted_at,
      updated_at: contract.updated_at
    }
  end
end
