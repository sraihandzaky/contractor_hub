defmodule ContractorHub.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :company_id, references(:companies, on_delete: :restrict), null: false
      add :actor_type, :string, null: false
      add :actor_id, :string, null: false
      add :action, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :integer, null: false
      add :changes, :map
      add :metadata, :map

      timestamps(updated_at: false)
    end

    create index(:audit_logs, [:company_id])
    create index(:audit_logs, [:resource_type, :resource_id])
    create index(:audit_logs, [:action])
    create index(:audit_logs, [:inserted_at])
  end
end
