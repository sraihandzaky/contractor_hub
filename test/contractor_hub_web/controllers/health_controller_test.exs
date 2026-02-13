defmodule ContractorHubWeb.HealthControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  test "GET /api/v1/health returns ok", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/health")

    response = json_response(conn, 200)
    assert response["status"] == "ok"
    assert response["timestamp"]
  end
end
