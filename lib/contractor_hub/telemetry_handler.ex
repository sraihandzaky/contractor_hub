defmodule ContractorHub.TelemetryHandler do
  @moduledoc """
  Attaches handlers to business telemetry events.
  Just logs for now
  """
  require Logger

  @events [
    [:contractor_hub, :contractor, :onboarded],
    [:contractor_hub, :contractor, :offboarded],
    [:contractor_hub, :contract, :activated],
    [:contractor_hub, :contract, :terminated],
    [:contractor_hub, :payment, :processed]
  ]

  def attach do
    :telemetry.attach_many(
      "contractor-hub-handler",
      @events,
      &handle_event/4,
      nil
    )
  end

  def handle_event([:contractor_hub, :contractor, :onboarded], measurements, metadata, _config) do
    Logger.info("[telemetry] contractor onboarded",
      country: metadata.country_code,
      company: metadata.company_id,
      count: measurements.count
    )
  end

  def handle_event([:contractor_hub, :contractor, :offboarded], measurements, metadata, _config) do
    Logger.info("[telemetry] contractor offboarded",
      company: metadata.company_id,
      count: measurements.count
    )
  end

  def handle_event([:contractor_hub, :contract, :activated], measurements, metadata, _config) do
    Logger.info("[telemetry] contract activated",
      currency: metadata.rate_currency,
      type: metadata.rate_type,
      rate: measurements.rate_amount
    )
  end

  def handle_event([:contractor_hub, :contract, :terminated], measurements, metadata, _config) do
    Logger.info("[telemetry] contract terminated",
      company: metadata.company_id,
      count: measurements.count
    )
  end

  def handle_event([:contractor_hub, :payment, :processed], measurements, metadata, _config) do
    Logger.info("[telemetry] payment processed",
      currency: metadata.currency,
      amount: measurements.amount,
      status: metadata.status
    )
  end
end
