defmodule ContractorHub.Repo do
  use Ecto.Repo,
    otp_app: :contractor_hub,
    adapter: Ecto.Adapters.Postgres
end
