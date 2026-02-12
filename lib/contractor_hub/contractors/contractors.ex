defmodule ContractorHub.Contractors do
  @moduledoc "Context for contractor lifecycle management."

  alias ContractorHub.{Repo, Scope, Filters, Sorting, Paginator, Audit}
  alias ContractorHub.Contractors.Contractor

  defp filters do
    [
      {"country_code", Filters.eq(:country_code)},
      {"status", Filters.eq(:status)},
      {"search", Filters.ilike(:full_name)}
    ]
  end

  @sortable_fields [:inserted_at, :full_name, :country_code]

  @doc "Onboards a new contractor with compliance validation and audit logging."
  def onboard_contractor(attrs, context) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:contractor,
      %Contractor{}
      |> Contractor.changeset(Map.put(attrs, "company_id", context.company_id))
    )
    |> Audit.log(
      "contractor.created",
      "contractor",
      fn %{contractor: c} -> c.id end,
      context,
      attrs
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{contractor: contractor}} -> {:ok, contractor}
      {:error, :contractor, changeset, _} -> {:error, changeset}
    end
  end

  @doc "Gets a single contractor scoped to company."
  def get_contractor(company_id, id) do
    Contractor
    |> Scope.for_company(company_id)
    |> Repo.get(id)
    |> case do
      nil -> {:error, :not_found}
      contractor -> {:ok, contractor}
    end
  end

  @doc "Lists contractors with filtering, sorting, and cursor pagination."
  def list_contractors(company_id, params \\ %{}) do
    Contractor
    |> Scope.for_company(company_id)
    |> Filters.apply_filters(params, filters())
    |> Sorting.apply(params, @sortable_fields)
    |> Paginator.paginate(params)
  end

  @doc "Updates a contractor's editable fields with audit logging."
  def update_contractor(company_id, id, attrs, context) do
    with {:ok, contractor} <- get_contractor(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contractor, Contractor.changeset(contractor, attrs))
      |> Audit.log("contractor.updated", "contractor", contractor.id, context, attrs)
      |> Repo.transaction()
      |> case do
        {:ok, %{contractor: contractor}} -> {:ok, contractor}
        {:error, :contractor, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Activates a pending contractor."
  def activate_contractor(company_id, id, context) do
    with {:ok, contractor} <- get_contractor(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contractor, Contractor.status_changeset(contractor, "active"))
      |> Audit.log(
        "contractor.activated",
        "contractor",
        contractor.id,
        context,
        %{previous_status: contractor.status, new_status: "active"}
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contractor: contractor}} -> {:ok, contractor}
        {:error, :contractor, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Offboards an active contractor."
  def offboard_contractor(company_id, id, context) do
    with {:ok, contractor} <- get_contractor(company_id, id) do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:contractor, Contractor.status_changeset(contractor, "offboarded"))
      |> Audit.log(
        "contractor.offboarded",
        "contractor",
        contractor.id,
        context,
        %{previous_status: contractor.status, new_status: "offboarded"}
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{contractor: contractor}} -> {:ok, contractor}
        {:error, :contractor, changeset, _} -> {:error, changeset}
      end
    end
  end
end
