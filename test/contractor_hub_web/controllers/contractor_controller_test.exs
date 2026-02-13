defmodule ContractorHubWeb.ContractorControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  import ContractorHub.Factory

  setup do
    {company, api_key} = insert_company_with_api_key()
    conn = build_conn() |> put_req_header("authorization", "Bearer #{api_key}")
    %{conn: conn, company: company}
  end

  describe "POST /api/v1/contractors" do
    test "onboards contractor successfully", %{conn: conn} do
      attrs = %{
        email: "new@example.com",
        full_name: "New Contractor",
        country_code: "US",
        tax_id: "123-45-6789"
      }

      conn = post(conn, ~p"/api/v1/contractors", contractor: attrs)

      assert %{
               "id" => _,
               "status" => "pending",
               "country_code" => "US"
             } = json_response(conn, 201)["data"]
    end

    test "returns RFC 7807 error for validation failure", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/contractors", contractor: %{email: ""})

      response = json_response(conn, 422)
      assert response["type"] == "validation_error"
      assert response["status"] == 422
      assert is_map(response["errors"])
    end

    test "returns 401 without API key" do
      conn = build_conn() |> post(~p"/api/v1/contractors", contractor: %{})

      response = json_response(conn, 401)
      assert response["type"] == "unauthorized"
    end
  end

  describe "GET /api/v1/contractors" do
    test "returns paginated results", %{conn: conn, company: company} do
      insert_list(5, :contractor, company: company)

      conn = get(conn, ~p"/api/v1/contractors", limit: 2)

      response = json_response(conn, 200)
      assert length(response["data"]) == 2
      assert response["meta"]["has_next"] == true
      assert response["meta"]["next_cursor"] != nil
    end

    test "filters by country_code", %{conn: conn, company: company} do
      insert(:contractor, company: company, country_code: "US", tax_id: "111-11-1111")
      insert(:contractor, company: company, country_code: "ID", tax_id: "12.345.678.9-012.345")

      conn = get(conn, ~p"/api/v1/contractors", country_code: "US")

      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["country_code"] == "US"
    end

    test "cannot see contractors from other companies", %{conn: conn} do
      other_company = insert(:company)
      insert_list(3, :contractor, company: other_company)

      conn = get(conn, ~p"/api/v1/contractors")

      response = json_response(conn, 200)
      assert response["data"] == []
    end
  end

  describe "GET /api/v1/contractors/:id" do
    test "returns contractor", %{conn: conn, company: company} do
      contractor = insert(:contractor, company: company)

      conn = get(conn, ~p"/api/v1/contractors/#{contractor.id}")

      response = json_response(conn, 200)["data"]
      assert response["id"] == contractor.id
      assert response["email"] == contractor.email
    end

    test "returns 404 for nonexistent contractor", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/contractors/0")

      response = json_response(conn, 404)
      assert response["type"] == "not_found"
    end
  end

  describe "PATCH /api/v1/contractors/:id" do
    test "updates contractor", %{conn: conn, company: company} do
      contractor = insert(:contractor, company: company)

      conn = patch(conn, ~p"/api/v1/contractors/#{contractor.id}", contractor: %{full_name: "Updated Name"})

      response = json_response(conn, 200)["data"]
      assert response["full_name"] == "Updated Name"
    end
  end

  describe "POST /api/v1/contractors/:id/activate" do
    test "activates a pending contractor", %{conn: conn, company: company} do
      contractor = insert(:contractor, company: company, status: "pending")

      conn = post(conn, ~p"/api/v1/contractors/#{contractor.id}/activate")

      response = json_response(conn, 200)["data"]
      assert response["status"] == "active"
    end
  end

  describe "POST /api/v1/contractors/:id/offboard" do
    test "offboards an active contractor", %{conn: conn, company: company} do
      contractor = insert(:contractor, company: company, status: "active")

      conn = post(conn, ~p"/api/v1/contractors/#{contractor.id}/offboard")

      response = json_response(conn, 200)["data"]
      assert response["status"] == "offboarded"
    end
  end
end
