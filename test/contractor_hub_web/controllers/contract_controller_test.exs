defmodule ContractorHubWeb.ContractControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  import ContractorHub.Factory

  setup do
    {company, api_key} = insert_company_with_api_key()
    contractor = insert(:contractor, company: company)
    conn = build_conn() |> put_req_header("authorization", "Bearer #{api_key}")
    %{conn: conn, company: company, contractor: contractor}
  end

  describe "POST /api/v1/contracts" do
    test "creates contract successfully", %{conn: conn, contractor: contractor} do
      attrs = %{
        contractor_id: contractor.id,
        title: "Dev Services",
        rate_amount: "5000.00",
        rate_currency: "USD",
        rate_type: "monthly",
        start_date: Date.to_iso8601(Date.utc_today())
      }

      conn = post(conn, ~p"/api/v1/contracts", contract: attrs)

      response = json_response(conn, 201)["data"]
      assert response["title"] == "Dev Services"
      assert response["status"] == "draft"
      assert response["contractor_id"] == contractor.id
    end

    test "returns 422 for missing required fields", %{conn: conn, contractor: contractor} do
      conn = post(conn, ~p"/api/v1/contracts", contract: %{contractor_id: contractor.id})

      response = json_response(conn, 422)
      assert response["type"] == "validation_error"
      assert response["status"] == 422
      assert is_map(response["errors"])
    end

    test "returns not_found for contractor from other company", %{conn: conn} do
      other_company = insert(:company)
      other_contractor = insert(:contractor, company: other_company)

      attrs = %{
        contractor_id: other_contractor.id,
        title: "Cross-company",
        rate_amount: "1000.00",
        rate_currency: "USD",
        rate_type: "hourly",
        start_date: Date.to_iso8601(Date.utc_today())
      }

      conn = post(conn, ~p"/api/v1/contracts", contract: attrs)

      response = json_response(conn, 404)
      assert response["type"] == "not_found"
    end
  end

  describe "GET /api/v1/contracts" do
    test "returns paginated list", %{conn: conn, company: company, contractor: contractor} do
      insert_list(3, :contract, company: company, contractor: contractor)

      conn = get(conn, ~p"/api/v1/contracts")

      response = json_response(conn, 200)
      assert length(response["data"]) == 3
      assert is_map(response["meta"])
    end
  end

  describe "GET /api/v1/contracts/:id" do
    test "returns contract", %{conn: conn, company: company, contractor: contractor} do
      contract = insert(:contract, company: company, contractor: contractor)

      conn = get(conn, ~p"/api/v1/contracts/#{contract.id}")

      response = json_response(conn, 200)["data"]
      assert response["id"] == contract.id
      assert response["title"] == contract.title
    end

    test "returns 404 for nonexistent contract", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/contracts/0")

      response = json_response(conn, 404)
      assert response["type"] == "not_found"
    end
  end

  describe "PATCH /api/v1/contracts/:id" do
    test "updates contract", %{conn: conn, company: company, contractor: contractor} do
      contract = insert(:contract, company: company, contractor: contractor)

      conn =
        patch(conn, ~p"/api/v1/contracts/#{contract.id}", contract: %{title: "Updated Title"})

      response = json_response(conn, 200)["data"]
      assert response["title"] == "Updated Title"
    end
  end

  describe "POST /api/v1/contracts/:id/activate" do
    test "activates a draft contract", %{conn: conn, company: company, contractor: contractor} do
      contract = insert(:contract, company: company, contractor: contractor, status: "draft")

      conn = post(conn, ~p"/api/v1/contracts/#{contract.id}/activate")

      response = json_response(conn, 200)["data"]
      assert response["status"] == "active"
    end

    test "fails on already-active contract", %{
      conn: conn,
      company: company,
      contractor: contractor
    } do
      contract = insert(:contract, company: company, contractor: contractor, status: "active")

      conn = post(conn, ~p"/api/v1/contracts/#{contract.id}/activate")

      response = json_response(conn, 422)
      assert response["type"] == "validation_error"
    end
  end

  describe "POST /api/v1/contracts/:id/complete" do
    test "completes an active contract", %{conn: conn, company: company, contractor: contractor} do
      contract = insert(:contract, company: company, contractor: contractor, status: "active")

      conn = post(conn, ~p"/api/v1/contracts/#{contract.id}/complete")

      response = json_response(conn, 200)["data"]
      assert response["status"] == "completed"
    end
  end

  describe "POST /api/v1/contracts/:id/terminate" do
    test "terminates an active contract", %{conn: conn, company: company, contractor: contractor} do
      contract = insert(:contract, company: company, contractor: contractor, status: "active")

      conn = post(conn, ~p"/api/v1/contracts/#{contract.id}/terminate")

      response = json_response(conn, 200)["data"]
      assert response["status"] == "terminated"
    end
  end
end
