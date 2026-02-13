defmodule ContractorHub.Audit.AuditLog do
  @moduledoc "Ecto schema and changesets for immutable audit log entries."
  use Ecto.Schema
  import Ecto.Changeset

  schema "audit_logs" do
    field :actor_type, :string
    field :actor_id, :string
    field :action, :string
    field :resource_type, :string
    field :resource_id, :integer
    field :changes, :map
    field :metadata, :map

    belongs_to :company, ContractorHub.Companies.Company

    timestamps(updated_at: false)
  end

  @required_fields [:company_id, :actor_type, :actor_id, :action, :resource_type, :resource_id]
  @optional_fields [:changes, :metadata]

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
