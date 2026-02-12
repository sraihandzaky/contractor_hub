defmodule ContractorHub.Audit do
  @moduledoc """
  Audit logging for all state-changing operations.
  """
  alias ContractorHub.Audit.AuditLog

  @spec log(Ecto.Multi.t(), any(), any(), any(), any()) :: Ecto.Multi.t()
  @doc """
  Appends an audit log insert to an Ecto.Multi.

  ## Parameters

  - `multi` — the existing Ecto.Multi pipeline
  - `action` — e.g. "contractor.created", "contract.activated"
  - `resource_type` — e.g. "contractor", "contract"
  - `resource_id_fn` — either an integer ID or a function `fn results -> id end`
    (use function when the resource was just created in a previous Multi step)
  - `context` — `%{company_id, api_key_id, metadata}` from the auth plug
  - `changes` — map of what changed (optional)
  -  NOTE: `\\\\` is fallback or default value

  ## Example

      Ecto.Multi.new()
      |> Ecto.Multi.insert(:contractor, changeset)
      |> Audit.log("contractor.created", "contractor", fn %{contractor: c} -> c.id end, context, attrs)
      |> Repo.transaction()
  """
  def log(multi, action, resource_type, resource_id_fn, context, changes \\ %{}) do
    Ecto.Multi.insert(multi, :audit_log, fn results ->
      resource_id =
        if is_function(resource_id_fn), do: resource_id_fn.(results), else: resource_id_fn

      %AuditLog{}
      |> AuditLog.changeset(%{
        company_id: context.company_id,
        actor_type: "api_key",
        actor_id: to_string(context.api_key_id),
        action: action,
        resource_type: resource_type,
        resource_id: resource_id,
        changes: changes,
        metadata: context.metadata
      })
    end)
  end

  @doc "Lists audit logs for a company, paginated and filterable."
  def list_logs(company_id, params) do
    AuditLog
    |> ContractorHub.Scope.for_company(company_id)
    |> ContractorHub.Filters.apply_filters(params, [
      {"resource_type", ContractorHub.Filters.eq(:resource_type)},
      {"resource_id", ContractorHub.Filters.eq(:resource_id)},
      {"action", ContractorHub.Filters.eq(:action)}
    ])
    |> ContractorHub.Paginator.paginate(params)
  end
end
