defmodule ContractorHubWeb.Plugs.AuthenticateTest do
  use ContractorHubWeb.ConnCase, async: true

  import ContractorHub.Factory

  defp me_path, do: ~p"/api/v1/companies/me"

  defp authed_conn(raw_key) do
    build_conn()
    |> put_req_header("authorization", "Bearer #{raw_key}")
  end

  defp get_me(conn) do
    get(conn, me_path())
  end

  test "rejects revoked API keys" do
    {company, raw_key} = insert_company_with_api_key()

    ContractorHub.Auth.ApiKey
    |> ContractorHub.Repo.get_by!(company_id: company.id)
    |> Ecto.Changeset.change(revoked_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> ContractorHub.Repo.update!()

    conn =
      raw_key
      |> authed_conn()
      |> get_me()

    assert json_response(conn, 401)["type"] == "unauthorized"
  end

  test "rejects missing Authorization header" do
    conn =
      build_conn()
      |> get_me()

    assert json_response(conn, 401)["type"] == "unauthorized"
  end

  test "rejects malformed Authorization header" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Token something")
      |> get_me()

    assert json_response(conn, 401)["type"] == "unauthorized"
  end

  test "rejects invalid key" do
    conn =
      "chub_sk_doesnotexist"
      |> authed_conn()
      |> get_me()

    assert json_response(conn, 401)["type"] == "unauthorized"
  end
end
