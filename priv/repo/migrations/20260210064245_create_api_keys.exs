defmodule ContractorHub.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :company_id, references(:companies, on_delete: :restrict), null: false
      add :key_hash, :string, null: false
      add :label, :string
      add :last_used_at, :utc_datetime
      add :revoked_at, :utc_datetime

      timestamps()
    end

    create unique_index(:api_keys, [:key_hash])
    create index(:api_keys, [:company_id])
  end
end
