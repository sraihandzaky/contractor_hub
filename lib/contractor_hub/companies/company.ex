defmodule ContractorHub.Companies.Company do
  @moduledoc "Ecto schema and changesets for company accounts."
  use Ecto.Schema
  import Ecto.Changeset

  schema "companies" do
    field :name, :string
    field :email, :string
    field :country_code, :string
    field :base_currency, :string, default: "USD"
    field :deleted_at, :utc_datetime

    has_many :api_keys, ContractorHub.Auth.ApiKey
    has_many :contractors, ContractorHub.Contractors.Contractor
    has_many :contracts, ContractorHub.Contracts.Contract

    timestamps()
  end

  @required_fields [:name, :email, :country_code]
  @optional_fields [:base_currency]
  @email_regex ~r/^[^\s]+@[^\s]+$/i

  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, @email_regex)
    |> validate_length(:country_code, is: 2)
    |> validate_length(:base_currency, is: 3)
    |> unique_constraint(:email)
  end
end
