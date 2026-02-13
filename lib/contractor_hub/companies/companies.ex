defmodule ContractorHub.Companies do
  @moduledoc "Context for company registration and management."

  alias ContractorHub.Auth
  alias ContractorHub.Companies.Company
  alias ContractorHub.Repo
  alias ContractorHub.Scope

  @doc """
  Registers a new company, generates an API key and return raw API key.
  """
  def register_company(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:company, Company.changeset(%Company{}, attrs))
    |> Ecto.Multi.run(:api_key, fn _repo, %{company: company} ->
      case Auth.create_api_key(company.id, "Default Key") do
        {:ok, raw_key, api_key} -> {:ok, %{raw_key: raw_key, api_key: api_key}}
        {:error, changeset} -> {:error, changeset}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{company: company, api_key: %{raw_key: raw_key}}} ->
        {:ok, company, raw_key}

      {:error, :company, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc "Gets an active (not soft-deleted) company by ID."
  def get_active_company(id) do
    Company
    |> Scope.active()
    |> Repo.get(id)
  end

  @doc "Gets a company by ID regardless of soft-delete status."
  def get_company(id) do
    Repo.get(Company, id)
  end

  @doc "Updates a company's editable fields."
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc "Soft-deletes a company by setting deleted_at."
  def deactivate_company(%Company{} = company) do
    company
    |> Ecto.Changeset.change(deleted_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end
end
