defmodule ContractorHub.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :country_code, :string, size: 2, null: false
      add :base_currency, :string, size: 3, default: "USD"
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create unique_index(:companies, [:email])
    create index(:companies, [:deleted_at])
  end
end
