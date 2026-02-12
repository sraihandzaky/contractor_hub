defmodule ContractorHubWeb.CountryController do
  use ContractorHubWeb, :controller

  alias ContractorHub.Compliance

  def index(conn, _params) do
    json(conn, %{data: Compliance.list_countries()})
  end
end
