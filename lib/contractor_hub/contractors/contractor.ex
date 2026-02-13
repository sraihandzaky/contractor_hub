defmodule ContractorHub.Contractors.Contractor do
  @moduledoc "Ecto schema and changesets for contractors, including status transitions and country-specific validations."
  use Ecto.Schema
  import Ecto.Changeset

  schema "contractors" do
    field :email, :string
    field :full_name, :string
    field :country_code, :string
    field :tax_id, :string
    field :bank_details, :map
    field :status, :string, default: "pending"

    belongs_to :company, ContractorHub.Companies.Company
    has_many :contracts, ContractorHub.Contracts.Contract

    timestamps()
  end

  @required_fields [:email, :full_name, :country_code, :company_id]
  @optional_fields [:tax_id, :bank_details]

  def changeset(contractor, attrs) do
    contractor
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:country_code, is: 2)
    |> validate_inclusion(:status, ~w(pending active offboarded))
    |> validate_country_supported()
    |> unique_constraint([:company_id, :email], error_key: :email)
    |> validate_country_requirements()
  end

  @valid_transitions %{
    "pending" => ~w(active offboarded),
    "active" => ~w(offboarded),
    "offboarded" => []
  }

  def status_changeset(contractor, new_status) do
    contractor
    |> change(status: new_status)
    |> validate_status_transition()
  end

  defp validate_status_transition(changeset) do
    old_status = changeset.data.status
    new_status = get_field(changeset, :status)
    allowed = Map.get(@valid_transitions, old_status, [])

    if new_status in allowed do
      changeset
    else
      add_error(changeset, :status,
        "cannot transition from #{old_status} to #{new_status}"
      )
    end
  end

  defp validate_country_supported(changeset) do
    country = get_field(changeset, :country_code)

    if country && !ContractorHub.Compliance.country_supported?(country) do
      add_error(changeset, :country_code, "is not a supported country")
    else
      changeset
    end
  end

  defp validate_country_requirements(changeset) do
    country = get_field(changeset, :country_code)

    if country do
      rules = ContractorHub.Compliance.get_rules(country)

      if rules[:requires_tax_id] do
        validate_required(changeset, [:tax_id],
          message: "#{rules.tax_id_label} is required for #{rules.name}"
        )
      else
        changeset
      end
    else
      changeset
    end
  end
end
