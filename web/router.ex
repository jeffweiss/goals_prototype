defmodule Sips.Router do
  use Sips.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/api", Sips do
    pipe_through :api
    post "register", RegistrationController, :create
    post "token", SessionController, :create, as: :login
  end

  scope "/api", Sips do
    pipe_through :api_auth
    get "/user/current", UserController, :current
    resources "user", UserController, only: [:show, :index] do
      get "goals", GoalController, :index, as: :goals
    end
    resources "/goals", GoalController, except: [:new, :edit] do
      get "measures", MeasureController, :index, as: :measures
      post "measures", MeasureController, :create, as: :measures
    end
    resources "/measures", MeasureController, except: [:new, :edit, :create]
  end
end
