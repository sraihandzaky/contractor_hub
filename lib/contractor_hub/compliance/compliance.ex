defmodule ContractorHub.Compliance do
  @moduledoc """
  Country-specific contractor compliance rules.

  TODO: Make a table for this
  """

  @country_rules %{
    "US" => %{
      name: "United States",
      requires_tax_id: true,
      tax_id_label: "SSN/EIN",
      payment_methods: [:ach, :wire],
      min_payment_days: 0,
      currency: "USD"
    },
    "DE" => %{
      name: "Germany",
      requires_tax_id: true,
      tax_id_label: "Steuernummer",
      vat_applicable: true,
      payment_methods: [:sepa, :wire],
      min_payment_days: 0,
      currency: "EUR"
    },
    "BR" => %{
      name: "Brazil",
      requires_tax_id: true,
      tax_id_label: "CPF",
      requires_nota_fiscal: true,
      payment_methods: [:pix, :wire],
      min_payment_days: 3,
      currency: "BRL"
    },
    "ID" => %{
      name: "Indonesia",
      requires_tax_id: true,
      tax_id_label: "NPWP",
      payment_methods: [:local_bank, :wire],
      min_payment_days: 1,
      currency: "IDR"
    },
    "GB" => %{
      name: "United Kingdom",
      requires_tax_id: true,
      tax_id_label: "UTR/NI Number",
      vat_applicable: true,
      payment_methods: [:bacs, :wire],
      min_payment_days: 0,
      currency: "GBP"
    },
    "SG" => %{
      name: "Singapore",
      requires_tax_id: true,
      tax_id_label: "NRIC/FIN",
      payment_methods: [:giro, :wire],
      min_payment_days: 0,
      currency: "SGD"
    },
    "NL" => %{
      name: "Netherlands",
      requires_tax_id: true,
      tax_id_label: "BSN",
      vat_applicable: true,
      payment_methods: [:sepa, :wire],
      min_payment_days: 0,
      currency: "EUR"
    },
    "CA" => %{
      name: "Canada",
      requires_tax_id: true,
      tax_id_label: "SIN",
      payment_methods: [:eft, :wire],
      min_payment_days: 0,
      currency: "CAD"
    }
  }

  @supported_countries Map.keys(@country_rules)

  def supported_countries, do: @supported_countries

  def list_countries do
    @country_rules
    |> Enum.map(fn {code, rules} ->
      %{
        code: code,
        name: rules.name,
        currency: rules.currency,
        requires_tax_id: rules[:requires_tax_id] || false,
        tax_id_label: rules[:tax_id_label],
        payment_methods: rules[:payment_methods] || [:wire]
      }
    end)
    |> Enum.sort_by(& &1.name)
  end

  def get_rules(country_code) do
    Map.get(@country_rules, country_code, default_rules())
  end

  def country_supported?(country_code), do: country_code in @supported_countries

  defp default_rules do
    %{
      name: "Other",
      requires_tax_id: false,
      payment_methods: [:wire],
      min_payment_days: 5,
      currency: "USD"
    }
  end
end
