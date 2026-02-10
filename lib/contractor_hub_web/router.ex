defmodule ContractorHubWeb.Router do
  use ContractorHubWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ContractorHubWeb do
    pipe_through :api
  end
end
