defmodule ContractorHubWeb.ContractorJSON do
  @moduledoc "JSON rendering functions for contractor responses."
  def render("index.json", %{page: page}) do
    %{
      data: Enum.map(page.data, &data/1),
      meta: page.meta
    }
  end

  def render("show.json", %{contractor: contractor}) do
    %{data: data(contractor)}
  end

  defp data(contractor) do
    %{
      id: contractor.id,
      email: contractor.email,
      full_name: contractor.full_name,
      country_code: contractor.country_code,
      tax_id: contractor.tax_id,
      bank_details: contractor.bank_details,
      status: contractor.status,
      inserted_at: contractor.inserted_at,
      updated_at: contractor.updated_at
    }
  end
end
