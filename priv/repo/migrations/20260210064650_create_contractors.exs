defmodule ContractorHub.Repo.Migrations.CreateContractors do
  use Ecto.Migration

  def change do
    create table(:contractors) do
      add :company_id, references(:companies, on_delete: :restrict), null: false
      add :email, :string, null: false
      add :full_name, :string, null: false
      add :country_code, :string, size: 2, null: false
      add :tax_id, :string
      add :bank_details, :map
      add :status, :string, default: "pending", null: false

      timestamps()
    end

    create unique_index(:contractors, [:company_id, :email])
    create index(:contractors, [:company_id])
    create index(:contractors, [:country_code])
    create index(:contractors, [:status])

    execute(
      "ALTER TABLE contractors ADD CONSTRAINT contractors_status_check CHECK (status IN ('pending', 'active', 'offboarded'))",
      "ALTER TABLE contractors DROP CONSTRAINT contractors_status_check"
    )
  end
end
