defmodule ContractorHub.ComplianceTest do
  use ExUnit.Case, async: true

  alias ContractorHub.Compliance

  test "returns correct rules for supported countries" do
    us_rules = Compliance.get_rules("US")
    assert us_rules.requires_tax_id == true
    assert us_rules.tax_id_label == "SSN/EIN"
    assert :ach in us_rules.payment_methods
  end

  test "returns correct rules for Indonesia" do
    id_rules = Compliance.get_rules("ID")
    assert id_rules.requires_tax_id == true
    assert id_rules.tax_id_label == "NPWP"
    assert id_rules.currency == "IDR"
  end

  test "returns default rules for unsupported countries" do
    rules = Compliance.get_rules("ZZ")
    assert rules.requires_tax_id == false
    assert :wire in rules.payment_methods
  end

  test "lists all supported countries with details" do
    countries = Compliance.list_countries()
    assert length(countries) == 8

    id_country = Enum.find(countries, &(&1.code == "ID"))
    assert id_country.name == "Indonesia"
    assert id_country.currency == "IDR"
  end

  test "country_supported? returns true for supported countries" do
    assert Compliance.country_supported?("US")
    assert Compliance.country_supported?("ID")
    assert Compliance.country_supported?("DE")
  end

  test "country_supported? returns false for unsupported countries" do
    refute Compliance.country_supported?("ZZ")
    refute Compliance.country_supported?("XX")
  end
end
