defmodule ContractorHub.Contracts.Contract do
  @moduledoc "Ecto schema and changesets for contracts, including lifecycle transitions."
  use Ecto.Schema
  import Ecto.Changeset

  schema "contracts" do
    field :title, :string
    field :description, :string
    field :rate_amount, :decimal
    field :rate_currency, :string
    field :rate_type, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :string, default: "draft"
    field :country_rules, :map

    belongs_to :company, ContractorHub.Companies.Company
    belongs_to :contractor, ContractorHub.Contractors.Contractor

    timestamps()
  end

  @required_fields [:company_id, :contractor_id, :title, :rate_amount, :rate_currency, :rate_type, :start_date]
  @optional_fields [:description, :end_date, :country_rules]

  def changeset(contract, attrs) do
    contract
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:rate_type, ~w(hourly monthly fixed))
    |> validate_number(:rate_amount, greater_than: 0)
    |> validate_length(:rate_currency, is: 3)
    |> validate_date_range()
    |> foreign_key_constraint(:contractor_id)
    |> foreign_key_constraint(:company_id)
  end

  @valid_transitions %{
    "draft" => ~w(active),
    "active" => ~w(completed terminated),
    "completed" => [],
    "terminated" => []
  }

  def activate_changeset(contract) do
    contract
    |> change(status: "active")
    |> validate_transition(contract.status, "active")
  end

  def complete_changeset(contract) do
    contract
    |> change(status: "completed")
    |> validate_transition(contract.status, "completed")
  end

  def terminate_changeset(contract) do
    contract
    |> change(status: "terminated")
    |> validate_transition(contract.status, "terminated")
  end

  defp validate_transition(changeset, from, to) do
    allowed = Map.get(@valid_transitions, from, [])

    if to in allowed do
      changeset
    else
      add_error(changeset, :status, "cannot transition from #{from} to #{to}")
    end
  end

  defp validate_date_range(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(end_date, start_date) == :lt do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
