defmodule ContractorHubWeb.HealthController do
  use ContractorHubWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok", timestamp: DateTime.utc_now()})
  end
end
