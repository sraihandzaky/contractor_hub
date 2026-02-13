defmodule ContractorHubWeb.ErrorJSONTest do
  use ContractorHubWeb.ConnCase, async: true

  test "renders 404" do
    assert ContractorHubWeb.ErrorJSON.render("404.json", %{}) ==
             %{
               type: "server_error",
               title: "Not Found",
               status: 500,
               detail: "An internal server error occurred"
             }
  end

  test "renders 500" do
    assert ContractorHubWeb.ErrorJSON.render("500.json", %{}) ==
             %{
               type: "server_error",
               title: "Internal Server Error",
               status: 500,
               detail: "An internal server error occurred"
             }
  end
end
