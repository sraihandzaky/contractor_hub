defmodule ContractorHub.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts) do
      add :company_id, references(:companies, on_delete: :restrict), null: false
      add :contractor_id, references(:contractors, on_delete: :restrict), null: false
      add :title, :string, null: false
      add :description, :text
      add :rate_amount, :decimal, precision: 12, scale: 2, null: false
      add :rate_currency, :string, size: 3, null: false
      add :rate_type, :string, null: false
      add :start_date, :date, null: false
      add :end_date, :date
      add :status, :string, default: "draft", null: false
      add :country_rules, :map

      timestamps()
    end

    create index(:contracts, [:company_id])
    create index(:contracts, [:contractor_id])
    create index(:contracts, [:status])

    execute(
      "ALTER TABLE contracts ADD CONSTRAINT contracts_status_check CHECK (status IN ('draft', 'active', 'completed', 'terminated'))",
      "ALTER TABLE contracts DROP CONSTRAINT contracts_status_check"
    )

    execute(
      "ALTER TABLE contracts ADD CONSTRAINT contracts_rate_type_check CHECK (rate_type IN ('hourly', 'monthly', 'fixed'))",
      "ALTER TABLE contracts DROP CONSTRAINT contracts_rate_type_check"
    )

    execute(
      "ALTER TABLE contracts ADD CONSTRAINT contracts_rate_positive CHECK (rate_amount > 0)",
      "ALTER TABLE contracts DROP CONSTRAINT contracts_rate_positive"
    )

    execute(
      "ALTER TABLE contracts ADD CONSTRAINT contracts_date_range CHECK (end_date IS NULL OR end_date >= start_date)",
      "ALTER TABLE contracts DROP CONSTRAINT contracts_date_range"
    )
  end
end
