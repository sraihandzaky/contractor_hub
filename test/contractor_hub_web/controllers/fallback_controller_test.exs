defmodule ContractorHubWeb.FallbackControllerTest do
  use ContractorHubWeb.ConnCase, async: true

  alias ContractorHubWeb.FallbackController

  test "renders 409 conflict" do
    conn =
      build_conn()
      |> FallbackController.call({:error, :conflict, "Already exists"})

    response = json_response(conn, 409)
    assert response["type"] == "conflict"
    assert response["status"] == 409
    assert response["detail"] == "Already exists"
  end
end
