defmodule ContractorHub.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :contractor_hub,
    adapter: Ecto.Adapters.Postgres
end
