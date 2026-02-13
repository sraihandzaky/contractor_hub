defmodule ContractorHubWeb.CompanyControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  import ContractorHub.Factory

  describe "POST /api/v1/companies" do
    test "creates company and returns API key" do
      conn =
        build_conn()
        |> post(~p"/api/v1/companies", company: %{
          name: "Acme Corp",
          email: "admin@acme.com",
          country_code: "US"
        })

      response = json_response(conn, 201)
      assert response["data"]["name"] == "Acme Corp"
      assert String.starts_with?(response["api_key"], "chub_sk_")
    end
  end

  describe "GET /api/v1/companies/me" do
    test "returns own company", %{} do
      {company, raw_key} = insert_company_with_api_key()

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{raw_key}")
        |> get(~p"/api/v1/companies/me")

      response = json_response(conn, 200)
      assert response["data"]["id"] == company.id
    end

    test "returns 401 without auth" do
      conn = build_conn() |> get(~p"/api/v1/companies/me")
      assert json_response(conn, 401)["type"] == "unauthorized"
    end

    test "returns 401 for deactivated company" do
      {company, raw_key} = insert_company_with_api_key()
      ContractorHub.Companies.deactivate_company(company)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{raw_key}")
        |> get(~p"/api/v1/companies/me")

      assert json_response(conn, 401)["type"] == "unauthorized"
    end
  end

  describe "POST /api/v1/companies - validation" do
    test "returns 422 for missing required fields" do
      conn =
        build_conn()
        |> post(~p"/api/v1/companies", company: %{})

      response = json_response(conn, 422)
      assert response["type"] == "validation_error"
      assert response["status"] == 422
      assert is_map(response["errors"])
    end
  end

  describe "PATCH /api/v1/companies/me" do
    test "updates company", %{} do
      {_company, raw_key} = insert_company_with_api_key()

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{raw_key}")
        |> patch(~p"/api/v1/companies/me", company: %{name: "Updated Corp"})

      response = json_response(conn, 200)
      assert response["data"]["name"] == "Updated Corp"
    end

    test "returns 401 without auth" do
      conn = build_conn() |> patch(~p"/api/v1/companies/me", company: %{name: "Nope"})
      assert json_response(conn, 401)["type"] == "unauthorized"
    end
  end
end
