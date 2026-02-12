defmodule ContractorHubWeb.Plugs.Authenticate do
  @moduledoc """
  API key authentication plug (same like interceptor or middleware).
  Extracts Bearer token from Authorization header, hashes it,
  looks up in DB, verifies company is not soft-deleted,
  and assigns current_company_id to conn.
  """
  import Plug.Conn

  alias ContractorHub.Auth
  alias ContractorHub.Companies

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         key_hash <- Auth.hash_key(token),
         %{} = api_key <- Auth.get_active_api_key(key_hash),
         {:ok, _company} <- verify_company_active(api_key.company_id) do
      # Track last usage
      Task.start(fn -> Auth.touch_api_key(api_key) end)

      conn
      |> assign(:current_company_id, api_key.company_id)
      |> assign(:api_key, api_key)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{
          type: "unauthorized",
          title: "Unauthorized",
          status: 401,
          detail: "Invalid or missing API key"
        })
        |> halt()
    end
  end

  defp verify_company_active(company_id) do
    case Companies.get_active_company(company_id) do
      nil -> {:error, :deactivated}
      company -> {:ok, company}
    end
  end
end
