defmodule ContractorHub.Contracts do
  @moduledoc "Context for contract lifecycle management."

  alias ContractorHub.{Repo, Scope, Filters, Sorting, Paginator, Audit}
  alias ContractorHub.Contracts.Contract
  alias ContractorHub.Contractors

  defp filters do
    [
      {"status", Filters.eq(:status)},
      {"rate_type", Filters.eq(:rate_type)},
      {"contractor_id", Filters.eq(:contractor_id)}
    ]
  end
  @sortable_fields [:inserted_at, :title, :start_date, :rate_amount]

  @doc "Creates a contract. Validates contractor belongs to same company."
  def create_contract(attrs, context) do
    # Verify contractor belongs to this company
    with {:ok, _contractor} <-
           Contractors.get_contractor(context.company_id, attrs["contractor_id"]) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:contract,
        %Contract{}
        |> Contract.changeset(Map.put(attrs, "company_id", context.company_id))
      )
      |> Audit.log(
        "contract.created",
        "contract",
        fn %{contract: c} -> c.id end,
        context,
        attrs
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contract: contract}} -> {:ok, contract}
        {:error, :contract, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Gets a single contract scoped to company."
  def get_contract(company_id, id) do
    Contract
    |> Scope.for_company(company_id)
    |> Repo.get(id)
    |> case do
      nil -> {:error, :not_found}
      contract -> {:ok, contract}
    end
  end

  @doc "Lists contracts with filtering, sorting, and cursor pagination."
  def list_contracts(company_id, params \\ %{}) do
    Contract
    |> Scope.for_company(company_id)
    |> Filters.apply_filters(params, filters())
    |> Sorting.apply(params, @sortable_fields)
    |> Paginator.paginate(params)
  end

  @doc "Updates a draft contract."
  def update_contract(company_id, id, attrs, context) do
    with {:ok, contract} <- get_contract(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contract, Contract.changeset(contract, attrs))
      |> Audit.log("contract.updated", "contract", contract.id, context, attrs)
      |> Repo.transaction()
      |> case do
        {:ok, %{contract: contract}} -> {:ok, contract}
        {:error, :contract, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Activates a draft contract."
  def activate_contract(company_id, id, context) do
    with {:ok, contract} <- get_contract(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contract, Contract.activate_changeset(contract))
      |> Audit.log(
        "contract.activated",
        "contract",
        contract.id,
        context,
        %{previous_status: contract.status, new_status: "active"}
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contract: contract}} ->
          ContractorHub.Telemetry.emit_contract_activated(contract)
          {:ok, contract}
        {:error, :contract, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Completes an active contract."
  def complete_contract(company_id, id, context) do
    with {:ok, contract} <- get_contract(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contract, Contract.complete_changeset(contract))
      |> Audit.log(
        "contract.completed",
        "contract",
        contract.id,
        context,
        %{previous_status: contract.status, new_status: "completed"}
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contract: contract}} -> {:ok, contract}
        {:error, :contract, changeset, _} -> {:error, changeset}
      end
    end
  end


  @doc "Terminates an active contract."
  def terminate_contract(company_id, id, context) do
    with {:ok, contract} <- get_contract(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contract, fn _ ->
        Contract.terminate_changeset(contract)
      end)
      |> Audit.log(
        "contract.terminated",
        "contract",
        contract.id,
        context,
        %{previous_status: contract.status, new_status: "terminated"}
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contract: contract}} ->
          ContractorHub.Telemetry.emit_contract_terminated(contract)
          {:ok, contract}
        {:error, :contract, changeset, _} -> {:error, changeset}
      end
    end
  end
end
