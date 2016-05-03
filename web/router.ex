defmodule Sips.Router do
  use Sips.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Sips do
    pipe_through :api
  end
end
