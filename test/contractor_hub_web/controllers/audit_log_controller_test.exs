defmodule ContractorHubWeb.AuditLogControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  import ContractorHub.Factory

  setup do
    {company, api_key} = insert_company_with_api_key()
    conn = build_conn() |> put_req_header("authorization", "Bearer #{api_key}")
    %{conn: conn, company: company}
  end

  describe "GET /api/v1/audit-logs" do
    test "returns paginated audit logs", %{conn: conn} do
      # Creating a contractor generates an audit log
      post(conn, ~p"/api/v1/contractors",
        contractor: %{
          email: "audit@example.com",
          full_name: "Audit Test",
          country_code: "US",
          tax_id: "123-45-6789"
        }
      )

      conn = get(conn, ~p"/api/v1/audit-logs")

      response = json_response(conn, 200)
      assert is_list(response["data"])
      assert [_ | _] = response["data"]

      log = hd(response["data"])
      assert Map.has_key?(log, "id")
      assert Map.has_key?(log, "actor_type")
      assert Map.has_key?(log, "action")
      assert Map.has_key?(log, "resource_type")
    end

    test "returns empty for company with no activity", %{} do
      # Create a fresh company with no activity
      {_other_company, other_key} = insert_company_with_api_key()
      conn = build_conn() |> put_req_header("authorization", "Bearer #{other_key}")

      conn = get(conn, ~p"/api/v1/audit-logs")

      response = json_response(conn, 200)
      assert response["data"] == []
    end
  end
end
