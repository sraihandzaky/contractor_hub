defmodule ContractorHub.Auth do
  @moduledoc "API key generation, verification, and management."

  alias ContractorHub.Auth.ApiKey
  alias ContractorHub.Repo

  import Ecto.Query

  @prefix "chub_sk_"

  @doc """
  Creates a new API key for a company.
  Returns {:ok, raw_key, api_key} where raw_key is the un-hashed key
  the client needs to store.
  """
  def create_api_key(company_id, label \\ nil) do
    raw_key = @prefix <> Base.url_encode64(:crypto.strong_rand_bytes(24))
    key_hash = hash_key(raw_key)

    result =
      %ApiKey{}
      |> ApiKey.changeset(%{company_id: company_id, key_hash: key_hash, label: label})
      |> Repo.insert()

    case result do
      {:ok, api_key} -> {:ok, raw_key, api_key}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc "Finds an active (non-revoked) API key by its hash."
  def get_active_api_key(key_hash) do
    ApiKey
    |> where([k], k.key_hash == ^key_hash and is_nil(k.revoked_at))
    |> Repo.one()
  end

  @doc "Updates last_used_at timestamp. Called async from the auth plug."
  def touch_api_key(%ApiKey{} = api_key) do
    api_key
    |> Ecto.Changeset.change(last_used_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end

  @doc "Hashes a raw API key with SHA-256."
  def hash_key(raw_key) do
    :crypto.hash(:sha256, raw_key) |> Base.encode16(case: :lower)
  end
end
