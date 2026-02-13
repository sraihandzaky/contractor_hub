defmodule ContractorHub.Telemetry do
  @moduledoc """
  Business-level telemetry events.
  Probably hook this to Datadog/Prometheus later?
  """
  require Logger

  def emit_contractor_onboarded(contractor) do
    :telemetry.execute(
      [:contractor_hub, :contractor, :onboarded],
      %{count: 1},
      %{country_code: contractor.country_code, company_id: contractor.company_id}
    )

    Logger.info("contractor_onboarded",
      contractor_id: contractor.id,
      company_id: contractor.company_id,
      country_code: contractor.country_code
    )
  end

  def emit_contractor_offboarded(contractor) do
    :telemetry.execute(
      [:contractor_hub, :contractor, :offboarded],
      %{count: 1},
      %{country_code: contractor.country_code, company_id: contractor.company_id}
    )

    Logger.info("contractor_offboarded",
      contractor_id: contractor.id,
      company_id: contractor.company_id
    )
  end

  def emit_contract_activated(contract) do
    :telemetry.execute(
      [:contractor_hub, :contract, :activated],
      %{count: 1, rate_amount: Decimal.to_float(contract.rate_amount)},
      %{rate_currency: contract.rate_currency, rate_type: contract.rate_type}
    )

    Logger.info("contract_activated",
      contract_id: contract.id,
      rate_currency: contract.rate_currency,
      rate_type: contract.rate_type
    )
  end

  def emit_contract_terminated(contract) do
    :telemetry.execute(
      [:contractor_hub, :contract, :terminated],
      %{count: 1},
      %{company_id: contract.company_id}
    )

    Logger.info("contract_terminated", contract_id: contract.id)
  end

  def emit_payment_processed(payment) do
    :telemetry.execute(
      [:contractor_hub, :payment, :processed],
      %{amount: Decimal.to_float(payment.amount)},
      %{currency: payment.currency, status: payment.status}
    )
  end
end
