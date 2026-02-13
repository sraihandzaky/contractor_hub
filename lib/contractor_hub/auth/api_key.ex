defmodule ContractorHub.Auth.ApiKey do
  @moduledoc "Ecto schema and changesets for API key authentication credentials."
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_keys" do
    field :key_hash, :string
    field :label, :string
    field :last_used_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :company, ContractorHub.Companies.Company

    timestamps()
  end

  @required_fields [:company_id, :key_hash]
  @optional_fields [:label]


  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:key_hash)
  end
end
