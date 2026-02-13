defmodule ContractorHubWeb.CountryControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  test "GET /api/v1/countries returns country list", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/countries")

    response = json_response(conn, 200)
    assert is_list(response["data"])
    assert length(response["data"]) > 0

    country = hd(response["data"])
    assert Map.has_key?(country, "code")
    assert Map.has_key?(country, "name")
  end
end
